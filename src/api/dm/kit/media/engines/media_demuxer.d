module api.dm.kit.media.engines.media_demuxer;

import api.core.utils.queues.ring_buffer_lf : RingBufferLF;
import api.core.utils.container_result : ContainerResult;
import api.dm.kit.media.engines.base_media_worker : BaseMediaWorker;
import api.dm.kit.media.engines.video_decoder : UVFrame;

import api.core.loggers.builtins.logger : Logger;
import core.sync.mutex : Mutex;

import Math = api.math;

import api.dm.lib.ffmpeg.native;

struct DemuxerContext
{
    shared Mutex mutex;

    bool isVideo;
    bool isAudio;

    int windowWidth;
    int windowHeight;

    AVFormatContext* formatCtx;

    int videoFrameIndex;
    int audioFrameIndex;
}

/**
 * Authors: initkfs
 */
class MediaDemuxer(size_t VideoQueueSize, size_t AudioQueueSize, size_t VideoBufferSize, size_t AudioBufferSize)
    : BaseMediaWorker
{
    protected
    {
        DemuxerContext context;

        RingBufferLF!(AVPacket*, VideoQueueSize)* videoPacketQueue;
        RingBufferLF!(AVPacket*, AudioQueueSize)* audioPacketQueue;

        RingBufferLF!(UVFrame, VideoBufferSize)* videoBuffer;
        RingBufferLF!(float, AudioBufferSize)* audioBuffer;
    }

    this(Logger logger,
        DemuxerContext context,
        typeof(videoPacketQueue) videoQueue,
        typeof(audioPacketQueue) audioQueue,
        typeof(videoBuffer) videoBuffer,
        typeof(audioBuffer) audioBuffer)
    {
        super(logger);

        assert(context.windowWidth > 0);
        assert(context.windowHeight > 0);
        assert(context.formatCtx);

        this.context = context;

        assert(videoQueue);
        this.videoPacketQueue = videoQueue;

        assert(audioQueue);
        this.audioPacketQueue = audioQueue;

        assert(videoBuffer);
        this.videoBuffer = videoBuffer;

        assert(audioBuffer);
        this.audioBuffer = audioBuffer;
    }

    override void run()
    {
        try
        {
            //version (EnableTrace)
            //{
                logger.tracef("Run demuxer");
            //}

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

            //version (EnableTrace)
            //{
                logger.trace("Start demuxer loop");
            //}

            while (true)
            {
                // if (state != WorkerState.play)
                // {
                //     continue;
                // }

                const packetRet = av_read_frame(context.formatCtx, packet);

                if (packetRet == codeEOF)
                {
                    logger.infof("Received EOF for media demuxer, break");
                    break;
                }

                import core.stdc.errno : EAGAIN;

                if (packetRet == AVERROR(EAGAIN))
                {
                    continue;
                }

                if (packetRet < 0)
                {
                    logger.error("Demuxer reading frame error: ", errorText(packetRet));
                }

                const nowMcs = av_gettime_relative();
                const timeSince = nowMcs - lastCheckDropTimeMcs;

                if (timeSince > dropCheckIntervalMcs)
                {
                    if ((droppedAudioPackets + droppedVideoPackets) > dropTreshold)
                    {
                        currDelayMs = currDelayMs * delayGrowFactor;
                        currDelayMs = Math.min(currDelayMs, maxDelayMs);

                        import core.time : dur;

                        logger.warningf("Detect dropped packets, video %s, audio %s, sleep %sms", droppedVideoPackets, droppedAudioPackets, currDelayMs);
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

                AVPacket* copy = allocCopy(packet);
                AVPacket*[1] packets = [copy];
                size_t isSend;
                if (context.isVideo && packet.stream_index == context.videoFrameIndex)
                {
                    isSend = videoPacketQueue.write(packets);
                    if (isSend != 1)
                    {
                        droppedVideoPackets++;
                        //av_packet_unref(packet);
                    }
                }
                else if (context.isAudio && packet.stream_index == context.audioFrameIndex)
                {
                    isSend = audioPacketQueue.write(packets);
                    if (isSend != 1)
                    {
                        droppedAudioPackets++;
                        import core.time : dur;

                        sleep(10.dur!"msecs");
                        //av_packet_unref(packet);
                    }
                }
            }

            av_packet_free(&packet);

            version (EnableTrace)
            {
                logger.trace("Demuxer finished work");
            }
        }
        catch (Exception e)
        {
            logger.error("Exception in demuxer: " ~ e.toString);
        }
        catch (Throwable th)
        {
            logger.error("Error in demuxer: " ~ th.toString);
            throw th;
        }
    }
}
