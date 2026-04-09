module api.dm.kit.media.engines.media_engine;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.media.audio.streams.audio_spec : AudioSpec, AudioFormat;
import api.dm.kit.media.audio.engines.audio_engine : AudioEngine;

import core.sync.mutex : Mutex;
import core.sync.condition : Condition;
import api.core.utils.queues.ring_buffer_spsc : RingBuffer;
import api.core.utils.sync : MutexLock;

import std.concurrency : spawn, send, receiveTimeout, Tid;
import core.thread.osthread : Thread;

import api.dm.kit.media.engines.media_demuxer : MediaDemuxer, DemuxerContext;
import api.dm.kit.media.engines.video_decoder : VideoDecoder;
import api.dm.kit.media.engines.audio_decoder : AudioDecoder;

import api.dm.kit.media.engines.video_decoder : VideoDecoder, UVFrame, VideoDecoderContext;
import api.dm.kit.media.engines.audio_decoder : AudioDecoder, AudioDecoderContext;

import api.dm.lib.ffmpeg.native;

import Math = api.math;

/**
 * Authors: initkfs
 */
class MediaEngine(
    size_t VideoQueueSize,
    size_t AudioQueueSize,
    size_t VideoBufferSize,
    size_t AudioBufferSize) : Sprite2d
{

    RingBuffer!(AVPacket*, VideoQueueSize) videoPacketQueue;
    RingBuffer!(AVPacket*, AudioQueueSize) audioPacketQueue;

    RingBuffer!(UVFrame, VideoBufferSize) videoBuffer;
    RingBuffer!(float, AudioBufferSize) audioBuffer;

    AudioEngine audioEngine;

    MediaDemuxer!(
        VideoQueueSize,
        AudioQueueSize,
        VideoBufferSize,
        AudioBufferSize) demuxer;

    VideoDecoder!(VideoQueueSize, VideoBufferSize) videoDecoder;
    AudioDecoder!(AudioQueueSize, AudioBufferSize) audioDecoder;

    string path;

    bool isFoundVideo;
    bool isFoundAudio;

    this(string path, float width = 200, float height = 200, AudioEngine audioEngine)
    {
        this.path = path;
        initSize(width, height);
        this.audioEngine = audioEngine;
    }

    protected
    {
        __gshared bool isRun;
    }

    protected
    {
        shared Mutex contextMutex;
        AVFormatContext* pFormatCtx;

        AVCodecParameters* vidpar, audpar;
        AVCodec* vidCodec, audCodec;
    }

    void delegate(ubyte[] yplane, ulong ypitch, ubyte[] uplane, ulong upitch, ubyte[] vplane, ulong vpitch) onUpdateYV;

    void load()
    {
        videoPacketQueue.initialize;
        audioPacketQueue.initialize;
        videoBuffer.initialize;
        audioBuffer.initialize;

        //TODO unsafe cast
        import std.string : toStringz;

        char* file = cast(char*) path.toStringz;

        assert(avformat_alloc_context);
        pFormatCtx = avformat_alloc_context();
        contextMutex = new shared Mutex;

        if (avformat_open_input(&pFormatCtx, file, null, null) != 0)
        {
            logger.error("Error ffmpeg file");
            return;
        }

        av_log_set_flags(AV_LOG_SKIP_REPEATED | AV_LOG_PRINT_LEVEL);
        av_dump_format(pFormatCtx, 0, file, 0);

        av_log_set_level(AV_LOG_ERROR);

        if (avformat_find_stream_info(pFormatCtx, null) < 0)
        {
            logger.error("Cannot find stream info. Quitting.");
            return;
        }

        int vidId = -1, audId = -1;

        AVRational videoTimeBase;
        AVRational videoAvgRate;
        
        AVRational audioTimeBase;
        AVRational audioAvgRate;

        foreach (int i; 0 .. pFormatCtx.nb_streams)
        {
            auto stream = pFormatCtx.streams[i];

            AVCodecParameters* codecParam = stream.codecpar;
            AVCodec* codec = avcodec_find_decoder(codecParam.codec_id);
            if (codecParam.codec_type == AVMediaType.AVMEDIA_TYPE_VIDEO && !isFoundVideo)
            {
                //fmt_ctx.streams[i].discard = AVDISCARD_ALL;
                vidCodec = codec;
                vidpar = codecParam;
                vidId = i;

                videoTimeBase = stream.time_base;
                videoAvgRate = stream.avg_frame_rate;

                //fpsrendering = 1.0 / (cast(float) rational.num / cast(float)(rational.den));
                isFoundVideo = true;
            }
            else if (codecParam.codec_type == AVMediaType.AVMEDIA_TYPE_AUDIO && !isFoundAudio)
            {
                audCodec = codec;
                audpar = codecParam;
                audId = i;

                audioTimeBase = stream.time_base;
                audioAvgRate = stream.avg_frame_rate;
                
                isFoundAudio = true;
            }

            if (isFoundVideo && isFoundAudio)
            {
                break;
            }
        }

        logger.infof("Open media file, video %s, audio %s, target w:%s,h:%s", isFoundVideo, isFoundAudio, width, height);

        demuxer = new typeof(demuxer)(
            logger,
            DemuxerContext(contextMutex, isFoundVideo, isFoundAudio, widthi, heighti, pFormatCtx, vidId, audId),
            &videoPacketQueue,
            &audioPacketQueue,
            &videoBuffer,
            &audioBuffer,
        );

        videoDecoder = new typeof(videoDecoder)(
            logger,
            VideoDecoderContext(vidpar, vidCodec, widthi, heighti, videoTimeBase, videoAvgRate),
            &videoPacketQueue,
            &videoBuffer);

        audioDecoder = new typeof(audioDecoder)(
            logger,
            AudioDecoderContext(audCodec, audpar, media.audioOutSpec, audioTimeBase, audioAvgRate),
            &audioPacketQueue,
            &audioBuffer, audioEngine);

        if (isFoundVideo)
        {
            videoDecoder.start;
        }

        if (isFoundAudio)
        {
            audioDecoder.start;
        }

        demuxer.start;
    }

    override void update(float dt)
    {
        super.update(dt);

        //if (!audioBuffer.isEmpty)
        //{

        // static float[4096] frames;
        // const readSize = audioBuffer.read(frames);
        // if (readSize == frames.length)
        // {
        //     media.audio.writeAudio(frames[]);
        // }
        //}

        //if (!audioBuffer.isEmpty && audioStream)
        //{
        // auto now = SDL_GetTicks();
        // auto elapsed = now - lastAudioUpdate;
        // size_t bytesNeed = (
        //     elapsed * media.audioOut.spec.freqHz * media.audioOut.spec.channels * short.sizeof) / 1000;

        // if (bytesNeed > 0)
        // {
        //     const bytesPerFrame = media.audioOut.spec.channels * short.sizeof;

        //     size_t alignedBytesFrame = (bytesNeed / bytesPerFrame) * bytesPerFrame;
        //     if (alignedBytesFrame > audioDecoder.buffer.size)
        //     {
        //         logger.errorf("Out of bounds audio buffer, need %s, but size %s", alignedBytesFrame, audioDecoder
        //                 .buffer.size);
        //     }
        //     lastAudioUpdate = now;
        // }
        //}

        updateVideo;
    }

    void updateVideo()
    {
        if (videoBuffer.isEmpty || !onUpdateYV)
        {
            return;
        }

        import api.dm.kit.media.engines.video_decoder : UVFrame;

        UVFrame vframe;
        UVFrame[1] vframes;
        const peekSize = videoBuffer.read(vframes, false);
        if (peekSize != 1)
        {
            logger.errorf("Error peek videoframe from buffer: %s", peekSize);
            return;
        }

        vframe = vframes[0];

        auto audioTimeSec = audioEngine.audioClock / media.audioOutSpec.freqHz;
        auto videoTimeSec = vframe.ptsSec;

        const syncThreshold = 0.1;
        const maxSyncThreshold = syncThreshold * 10;

        float diffTime = videoTimeSec - audioTimeSec;
        if (Math.abs(diffTime) > maxSyncThreshold)
        {
            logger.warningf("Video and audio out of sync by more than %f: %f", maxSyncThreshold, diffTime);
            //audioSamplesCount += cast(size_t)(diffTime * 48000);
        }

        //video ahead
        if (diffTime > syncThreshold)
        {
            return;
        }
        //video behind 
        else if (diffTime < -0.2)
        {
            //TODO double read!
            size_t countRead = videoBuffer.read(vframes);
            if (countRead != 1)
            {
                return;
            }
            vframes[0].free;
            return;
        }

        size_t countRead = videoBuffer.read(vframes);
        if (countRead != 1)
        {
            return;
        }

        vframe = vframes[0];
        scope (exit)
        {
            vframe.free;
        }

        //TODO runtime checks
        assert(vframe.yPlane.length > 0);
        assert(vframe.uPlane.length > 0);
        assert(vframe.vPlane.length > 0);

        onUpdateYV(vframe.yPlane, vframe.yPitch, vframe.uPlane, vframe.uPitch, vframe.vPlane, vframe
                .vPitch);
    }

    __gshared float audioTimeSec;
    __gshared ulong audioSamplesCount;

    // void handleAudioData(SDL_AudioStream* stream, int additional_amount, int total_amount) nothrow
    // {
    //     try
    //     {

    // if (!audioBuffer.isEmpty)
    // {
    //     audioBuffer.mutex.lock_nothrow;
    //     scope (exit)
    //     {
    //         audioBuffer.mutex.unlock_nothrow;
    //     }

    //     if (!isRun)
    //     {
    //         auto upSize = cast(size_t) audioBuffer.sizeLimit * 0.5;
    //         if (audioBuffer.size < upSize)
    //         {
    //             return;
    //         }
    //         isRun = true;
    //     }

    //     auto newAmount = additional_amount * 16;
    //     auto available = SDL_GetAudioStreamAvailable(stream);
    //     if (available < newAmount && newAmount < audioBuffer.size)
    //     {
    //         additional_amount = newAmount;
    //     }

    //     void updateClock() nothrow
    //     {
    //         audioSamplesCount += additional_amount / (2 * float.sizeof);

    //         size_t bytesPerSample = float.sizeof * 2;
    //         auto queueBytes = SDL_GetAudioStreamQueued(stream);
    //         float buffTime = cast(float) queueBytes / (44000 * bytesPerSample);
    //         // float buffTime = 0;
    //         audioTimeSec = audioSamplesCount / 44000.0 - buffTime;
    //     }

    //     updateClock;

    //     //debug
    //     //{
    //     const isRead = audioBuffer.read((scope ubyte[] buff, ubyte[] rest) @safe {

    //         () @trusted {

    //             if (buff.length == 0)
    //             {
    //                 return;
    //             }

    //             if (rest.length == 0)
    //             {
    //                 //TODO SDL_PutAudioStreamDataNoCopy
    //                 SDL_PutAudioStreamData(stream, &buff[0], cast(int) buff.length);
    //                 return;
    //             }
    //             //TODO pool

    //             import core.memory : pureMalloc, pureFree;

    //             const elems = buff.length + rest.length;
    //             auto fullBuffPtr = pureMalloc(
    //                 elems);
    //             assert(fullBuffPtr);
    //             auto fullBuff = fullBuffPtr[0 .. elems];

    //             size_t index;
    //             fullBuff[0 .. buff.length] = buff;
    //             index += buff.length;
    //             fullBuff[index .. (index + rest.length)] = rest;

    //             SDL_PutAudioStreamData(stream, &fullBuff[0], cast(int) elems);
    //             scope (exit)
    //             {
    //                 pureFree(fullBuffPtr);
    //             }
    //         }();
    //     }, additional_amount);

    //     import api.core.utils.container_result : ContainerResult;

    //     if (isRead != ContainerResult.success)
    //     {
    //         debug
    //         {
    //             import std.stdio : writefln;

    //             // writefln("Read %s bytes for audiodevice: %s. Size: %s, ri: %s, wi: %s", additional_amount, isRead, audioBuffer
    //             //     .size, audioBuffer.readIndex, audioBuffer.writeIndex);
    //         }
    //     }
    // }
    //     }

    //     catch (Exception e)
    //     {
    //         import std.stdio : stderr, writeln;

    //         debug stderr.writeln("Error in audio callback: ", e);
    //     }
    // }

    override void dispose()
    {
        super.dispose;

        if (demuxer && demuxer.isRunning)
        {
            demuxer.stop;
            version (EnableTrace)
            {
                logger.trace("Try stop demuxer");
            }
        }

        if (videoDecoder && videoDecoder.isRunning)
        {
            videoDecoder.stop;
            version (EnableTrace)
            {
                logger.trace("Try stop video decoder");
            }
        }

        if (audioDecoder && audioDecoder.isRunning)
        {
            audioDecoder.stop;
            version (EnableTrace)
            {
                logger.trace("Try stop audio decoder");
            }
        }
    }

}
