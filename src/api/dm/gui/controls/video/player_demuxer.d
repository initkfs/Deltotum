module api.dm.gui.controls.video.player_demuxer;

import api.core.utils.structs.rings.ring_buffer : RingBuffer;
import api.dm.gui.controls.video.base_player_worker : BasePlayerWorker;
import api.dm.com.audio.com_audio_device : ComAudioSpec, ComAudioFormat;

import api.dm.gui.controls.video.video_decoder : VideoDecoder;
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
class PlayerDemuxer(size_t VideoBufferPacketSize, size_t AudioBufferPacketSize, size_t VideoBufferSize, size_t AudioBufferSize) : BasePlayerWorker
{
    protected
    {
        string path;
        RingBuffer!(AVPacket*, VideoBufferPacketSize) videoPacketQueue;
        RingBuffer!(AVPacket*, AudioBufferPacketSize) audioPacketQueue;

        RingBuffer!(ubyte, VideoBufferSize) videoBuffer;
        RingBuffer!(ubyte, AudioBufferSize) audioBuffer;

        ComAudioSpec outAudioSpec;

        int windowWidth;
        int windowHeight;
    }

    VideoDecoder!(VideoBufferPacketSize, VideoBufferSize) videoDecoder;
    AudioDecoder!(AudioBufferPacketSize, AudioBufferSize) audioDecoder;

    this(Logger logger, string path, int windowWidth, int windowHeight, ComAudioSpec outAudioSpec)
    {
        super(logger);
        this.path = path;
        this.windowWidth = windowWidth;
        this.windowHeight = windowHeight;
        this.outAudioSpec = outAudioSpec;
    }

    override void run()
    {
        double fpsrendering = 0.0;

        videoPacketQueue = typeof(videoPacketQueue)(new shared Mutex);
        audioPacketQueue = typeof(audioPacketQueue)(new shared Mutex);

        videoBuffer = typeof(videoBuffer)(new shared Mutex);
        audioBuffer = typeof(audioBuffer)(new shared Mutex);

        logger.tracef("Run demuxer on %s, w:%s,h:%s", path, windowWidth, windowHeight);

        char* file = cast(char*) path.toStringz;

        AVFormatContext* pFormatCtx = avformat_alloc_context();

        if (avformat_open_input(&pFormatCtx, file, null, null) != 0)
        {
            logger.error("Error ffmpeg file");
            return;
        }

        av_log_set_flags(AV_LOG_SKIP_REPEATED | AV_LOG_PRINT_LEVEL);
        av_log_set_level(AV_LOG_ERROR);

        av_dump_format(pFormatCtx, 0, file, 0);

        if (avformat_find_stream_info(pFormatCtx, null) < 0)
        {
            logger.error("Cannot find stream info. Quitting.");
            return;
        }

        bool foundVideo = false, foundAudio = false;

        AVCodecParameters* vidpar, audpar;
        int vidId = -1, audId = -1;

        AVCodec* vidCodec, audCodec;

        foreach (int i; 0 .. pFormatCtx.nb_streams)
        {
            AVCodecParameters* codecParam = pFormatCtx.streams[i].codecpar;
            AVCodec* codec = avcodec_find_decoder(codecParam.codec_id);
            if (codecParam.codec_type == AVMEDIA_TYPE_VIDEO && !foundVideo)
            {
                vidCodec = codec;
                vidpar = codecParam;
                vidId = i;
                AVRational rational = pFormatCtx.streams[i].avg_frame_rate;
                fpsrendering = 1.0 / (cast(double) rational.num / cast(double)(rational.den));
                foundVideo = true;
            }
            else if (codecParam.codec_type == AVMEDIA_TYPE_AUDIO && !foundAudio)
            {
                audCodec = codec;
                audpar = codecParam;
                audId = i;
                foundAudio = true;
            }

            if (foundVideo && foundAudio)
            {
                break;
            }
        }

        logger.tracef("Demuxer state, video %s, audio %s", foundVideo, foundAudio);

        videoDecoder = new typeof(videoDecoder)(logger, vidCodec, vidpar, windowWidth, windowHeight);
        audioDecoder = new typeof(audioDecoder)(logger, audCodec, audpar, outAudioSpec, &audioPacketQueue, &audioBuffer);

        //videoDecoder.start;
        audioDecoder.start;

        //data_size + AV_INPUT_BUFFER_PADDING_SIZE
        AVPacket* packet = av_packet_alloc();

        logger.trace("Start demuxer loop");

        // if (packet.stream_index == video_stream_idx)
        // {
        //     SDL_LockMutex(video_queue_mutex);
        //     if (video_packets.size() < MAX_VIDEO_QUEUE)
        //     {
        //         video_packets.push(packet);
        //     }
        //     else
        //     {
        //         av_packet_unref(&packet); // Отбрасываем, если очередь переполнена
        //     }
        //     SDL_UnlockMutex(video_queue_mutex);
        // }
        // else if (packet.stream_index == audio_stream_idx)
        // {
        //     SDL_LockMutex(audio_queue_mutex);
        //     if (audio_packets.size() < MAX_AUDIO_QUEUE)
        //     {
        //         audio_packets.push(packet);
        //     }
        //     else
        //     {
        //         av_packet_unref(&packet); // Отбрасываем лишнее аудио
        //         SDL_Delay(5); // Замедляем чтение, если аудио накапливается
        //     }
        //     SDL_UnlockMutex(audio_queue_mutex);
        // }

        // void video_thread()
        // {
        //     while (running)
        //     {
        //         SDL_LockMutex(video_queue_mutex);
        //         if (!video_packets.empty())
        //         {
        //             AVPacket packet = video_packets.front();
        //             video_packets.pop();
        //             SDL_UnlockMutex(video_queue_mutex);

        //             avcodec_send_packet(video_codec_ctx, &packet);
        //             // ... декодирование и рендеринг ...
        //         }
        //         else
        //         {
        //             SDL_UnlockMutex(video_queue_mutex);
        //             SDL_Delay(1);
        //         }
        //     }
        // }

        long dropCheckIntervalMcs = 1000;
        size_t dropTreshold = 5;
        size_t delayGrowFactor = 2;
        
        size_t lastCheckDropTimeMcs = 0;
        long initDelayMs = 100;
        long currDelayMs = initDelayMs;
        long maxDelayMs = 5000;

        size_t droppedAudioPackets = 0;
        size_t droppedVideoPackets = 0;

        while (true)
        {
            const packetRet = av_read_frame(pFormatCtx, packet);
            
            //TODO AVERROR_EOF
            if(packetRet == FFERRTAG( 'E','O','F',' ')){
                if(videoDecoder && videoDecoder.isRunning){
                    videoDecoder.setEnd;
                }

                if(audioDecoder && audioDecoder.isRunning){
                    audioDecoder.setEnd;
                }

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

                        logger.tracef("Detect dropped packets, video %s, audio %s, sleep %sms", droppedVideoPackets, droppedAudioPackets, currDelayMs);
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
                    //TODO isFull + writeSync = race condition
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
                        const isWrite = videoPacketQueue.writeSync(packets);
                        //import std;

                        //debug writeln("Send video packet ", isWrite);
                    }
                }
                else if (packet.stream_index == audId)
                {
                    if (audioPacketQueue.isFull)
                    {
                        droppedVideoPackets++;
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
                        const isWrite = audioPacketQueue.writeSync(slice);

                        //import std;

                        //debug writeln("Send audio packet ", isWrite);
                    }
                }
            }
        }

        av_packet_free(&packet);

        logger.trace("Demuxer work end");
    }

    override bool stop()
    {
        bool isStop = super.stop;
        if (videoDecoder && videoDecoder.isRunning)
        {
            videoDecoder.stop;
        }

        if (audioDecoder && audioDecoder.isRunning)
        {
            audioDecoder.stop;
        }
        return isStop;
    }
}
