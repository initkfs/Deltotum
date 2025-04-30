module api.dm.gui.controls.video.player_demuxer;

import api.core.utils.structs.rings.ring_buffer : RingBuffer;
import api.core.utils.structs.container_result : ContainerResult;
import api.dm.gui.controls.video.base_player_worker : BasePlayerWorker;
import api.dm.com.audio.com_audio_device : ComAudioSpec, ComAudioFormat;

import api.dm.gui.controls.video.video_decoder : VideoDecoder, UVFrame;
import api.dm.gui.controls.video.audio_decoder : AudioDecoder;

import std.logger : Logger;
import std.string : toStringz;

import Math = api.math;

import core.sync.mutex : Mutex;
import core.sync.condition : Condition;

import cffmpeg;

/**
 * Authors: initkfs
 */
class PlayerDemuxer(size_t VideoQueueSize, size_t AudioQueueSize, size_t VideoBufferSize, size_t AudioBufferSize)
    : BasePlayerWorker
{
    protected
    {
        AVFormatContext* pFormatCtx;
        int vidId, audId;

        RingBuffer!(AVPacket*, VideoQueueSize)* videoPacketQueue;
        RingBuffer!(AVPacket*, AudioQueueSize)* audioPacketQueue;

        RingBuffer!(UVFrame, VideoBufferSize)* videoBuffer;
        RingBuffer!(ubyte, AudioBufferSize)* audioBuffer;

        ComAudioSpec outAudioSpec;

        int windowWidth;
        int windowHeight;
    }

    this(Logger logger, int windowWidth, int windowHeight, ComAudioSpec outAudioSpec,
        typeof(videoPacketQueue) videoQueue,
        typeof(audioPacketQueue) audioQueue,
        typeof(videoBuffer) videoBuffer,
        typeof(audioBuffer) audioBuffer, AVFormatContext* pFormatCtx, int vidId, int audId)
    {
        super(logger);
        this.windowWidth = windowWidth;
        this.windowHeight = windowHeight;
        this.outAudioSpec = outAudioSpec;

        assert(videoQueue);
        this.videoPacketQueue = videoQueue;

        assert(audioQueue);
        this.audioPacketQueue = audioQueue;

        assert(videoBuffer);
        this.videoBuffer = videoBuffer;

        assert(audioBuffer);
        this.audioBuffer = audioBuffer;

        assert(pFormatCtx);
        this.pFormatCtx = pFormatCtx;

        this.vidId = vidId;
        this.audId = audId;
    }

    override void run()
    {
        logger.tracef("Run demuxer");

        //data_size + AV_INPUT_BUFFER_PADDING_SIZE
        AVPacket* packet = av_packet_alloc();

        long dropCheckIntervalMcs = 1000;
        size_t dropTreshold = 20;
        size_t delayGrowFactor = 2;

        size_t lastCheckDropTimeMcs = 0;
        long initDelayMs = 100;
        long currDelayMs = initDelayMs;
        long maxDelayMs = 1000;

        size_t droppedAudioPackets = 0;
        size_t droppedVideoPackets = 0;

        logger.trace("Start demuxer loop");

        while (true)
        {
            const packetRet = av_read_frame(pFormatCtx, packet);

            //TODO AVERROR_EOF
            if (packetRet == FFERRTAG('E', 'O', 'F', ' '))
            {
                logger.trace("Received EOF for media demuxer, break");
                break;
            }

            if (packetRet >= 0)
            {
                const nowMcs = av_gettime_relative();
                const timeSince = nowMcs - lastCheckDropTimeMcs;

                if (timeSince > dropCheckIntervalMcs)
                {
                    if ((droppedAudioPackets + droppedVideoPackets) > dropTreshold)
                    {
                        currDelayMs = currDelayMs * delayGrowFactor;
                        currDelayMs = Math.min(currDelayMs, maxDelayMs);

                        import core.time : dur;

                        // logger.tracef("Detect dropped packets, video %s, audio %s, sleep %sms", droppedVideoPackets, droppedAudioPackets, currDelayMs);
                        sleep(currDelayMs.dur!"msecs");
                    }
                    else
                    {
                        if (currDelayMs != initDelayMs)
                        {
                            currDelayMs = initDelayMs;
                        }
                    }

                    droppedAudioPackets = 0;
                    droppedAudioPackets = 0;
                    lastCheckDropTimeMcs = nowMcs;
                }

                if (packet.stream_index == vidId)
                {
                    videoPacketQueue.mutex.lock;
                    scope (exit)
                    {
                        videoPacketQueue.mutex.unlock;
                    }

                    if (videoPacketQueue.isFull)
                    {
                        droppedVideoPackets++;
                        av_packet_unref(packet);

                        //import std;
                        // debug writeln("Discard video packet");
                    }
                    else
                    {
                        AVPacket* copy = av_packet_alloc();
                        av_packet_ref(copy, packet);

                        AVPacket*[1] packets = [copy];
                        const isWrite = videoPacketQueue.write(packets);
                        if (isWrite != ContainerResult.success)
                        {
                            logger.trace("Error sending video packet to queue: ", isWrite);
                        }
                    }
                }
                else if (packet.stream_index == audId)
                {
                    audioPacketQueue.mutex.lock;
                    scope (exit)
                    {
                        audioPacketQueue.mutex.unlock;
                    }

                    if (audioPacketQueue.isFull)
                    {
                        droppedAudioPackets++;
                        import core.time : dur;

                        sleep(10.dur!"msecs");

                        av_packet_unref(packet);

                        //import std;
                        //debug writeln("Discard audio packet");
                    }
                    else
                    {
                        AVPacket* copy = av_packet_alloc();
                        av_packet_ref(copy, packet);

                        AVPacket*[1] slice = [copy];
                        const isWrite = audioPacketQueue.write(slice);

                        if (isWrite != ContainerResult.success)
                        {
                            logger.trace("Error sending audio packet to decoder", isWrite);
                        }
                    }
                }
            }
        }

        av_packet_free(&packet);

        logger.trace("Demuxer finished work");
    }
}
