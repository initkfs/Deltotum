module api.dm.gui.controls.video.video_player;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.back.sdl3.sounds.sdl_audio_stream : SdlAudioStream;
import api.dm.com.audio.com_audio_device : ComAudioSpec, ComAudioFormat;

import core.sync.mutex : Mutex;
import core.sync.condition : Condition;
import api.core.utils.structs.rings.ring_buffer : RingBuffer;
import api.core.utils.structs.container_result : ContainerResult;
import api.core.utils.sync : MutexLock;

import std.concurrency : spawn, send, receiveTimeout, Tid;
import core.thread.osthread : Thread;

import api.dm.gui.controls.video.player_demuxer : PlayerDemuxer;
import api.dm.gui.controls.video.video_decoder : VideoDecoder;
import api.dm.gui.controls.video.audio_decoder : AudioDecoder;

import api.dm.gui.controls.video.video_decoder : VideoDecoder, UVFrame;
import api.dm.gui.controls.video.audio_decoder : AudioDecoder;

import cffmpeg;
import csdl;

import Math = api.math;

struct AudioDataCallback
{
    void delegate(SDL_AudioStream*, int, int) nothrow @nogc dg;
}

static extern (C) void streamCallback(void* userdata, SDL_AudioStream* stream, int additional_amount, int total_amount) nothrow @nogc
{
    AudioDataCallback* callbackData = cast(AudioDataCallback*) userdata;
    assert(callbackData);
    assert(callbackData.dg);
    callbackData.dg(stream, additional_amount, total_amount);
}

auto mediaPlayer(
    size_t VideoQueueSize = 8192,
    size_t AudioQueueSize = 40960,
    size_t VideoBufferSize = 8192,
    size_t AudioBufferSize = 1638400)()
{

    return new VideoPlayer!(
        VideoQueueSize,
        AudioQueueSize,
        VideoBufferSize,
        AudioBufferSize);
}

/**
 * Authors: initkfs
 */
class VideoPlayer(
    size_t VideoQueueSize,
    size_t AudioQueueSize,
    size_t VideoBufferSize,
    size_t AudioBufferSize) : Control
{

    RingBuffer!(AVPacket*, VideoQueueSize) videoPacketQueue;
    RingBuffer!(AVPacket*, AudioQueueSize) audioPacketQueue;

    RingBuffer!(UVFrame, VideoBufferSize) videoBuffer;
    RingBuffer!(ubyte, AudioBufferSize) audioBuffer;

    PlayerDemuxer!(
        VideoQueueSize,
        AudioQueueSize,
        VideoBufferSize,
        AudioBufferSize) demuxer;

    VideoDecoder!(VideoQueueSize, VideoBufferSize) videoDecoder;
    AudioDecoder!(AudioQueueSize, AudioBufferSize) audioDecoder;

    this()
    {
        initSize(300, 200);
        isDrawBounds = true;
    }

    Texture2d texture;

    SdlAudioStream audioStream;

    shared Mutex contextMutex;
    shared Mutex audioMutex;

    ulong lastAudioUpdate;

    private
    {
        __gshared bool isRun;
    }

    AudioDataCallback audioDataCallback;

    protected
    {
        AVFormatContext* pFormatCtx;
        AVCodecParameters* vidpar, audpar;
        AVCodec* vidCodec, audCodec;
        bool foundVideo, foundAudio;
    }

    override void create()
    {
        super.create;

        texture = new Texture2d(width, height);
        addCreate(texture);
        texture.createMutYV;

        int windowWidth = cast(int) texture.width;
        int windowHeight = cast(int) texture.height;

        audioDataCallback = AudioDataCallback(&handleAudioData);

        videoPacketQueue = typeof(videoPacketQueue)(new shared Mutex);
        audioPacketQueue = typeof(audioPacketQueue)(new shared Mutex);

        videoBuffer = typeof(videoBuffer)(new shared Mutex);
        videoBuffer.isWriteForFill = true;
        audioBuffer = typeof(audioBuffer)(new shared Mutex);
        audioBuffer.isWriteForFill = true;

        char* file = cast(char*) "/home/user/sdl-music/WING_IT.mp4";

        pFormatCtx = avformat_alloc_context();

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

        foreach (int i; 0 .. pFormatCtx.nb_streams)
        {
            auto stream = pFormatCtx.streams[i];

            AVCodecParameters* codecParam = stream.codecpar;
            AVCodec* codec = avcodec_find_decoder(codecParam.codec_id);
            if (codecParam.codec_type == AVMEDIA_TYPE_VIDEO && !foundVideo)
            {
                //fmt_ctx.streams[i].discard = AVDISCARD_ALL;
                vidCodec = codec;
                vidpar = codecParam;
                vidId = i;

                videoTimeBase = stream.time_base;
                videoAvgRate = stream.avg_frame_rate;

                //fpsrendering = 1.0 / (cast(double) rational.num / cast(double)(rational.den));
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

        logger.tracef("Media file, video %s, audio %s, target w:%s,h:%s", foundVideo, foundAudio, windowWidth, windowHeight);

        demuxer = new typeof(demuxer)(logger, cast(
                int) texture.width, cast(
                int) texture.height, media.audioOut.spec, &videoPacketQueue, &audioPacketQueue, &videoBuffer, &audioBuffer, pFormatCtx, vidId, audId);

        videoDecoder = new typeof(videoDecoder)(logger, vidCodec, vidpar, windowWidth, windowHeight, &videoPacketQueue, &videoBuffer, videoTimeBase, videoAvgRate);
        audioDecoder = new typeof(audioDecoder)(logger, audCodec, audpar, media.audioOut.spec, &audioPacketQueue, &audioBuffer);

        videoDecoder.start;
        audioDecoder.start;

        demuxer.start;

        lastAudioUpdate = SDL_GetTicks();
    }

    override void update(double dt)
    {
        super.update(dt);

        if (audioDecoder && audioDecoder.isRunning)
        {
            if (!audioStream)
            {
                audioStream = new SdlAudioStream(audioDecoder.srcSpec, media.audioOut.spec);
                if (const err = audioStream.setGetByDeviceCallback(&streamCallback, cast(void*)&audioDataCallback))
                {
                    logger.error("Error setting audio stream callback: ", err.toString);
                    return;
                }
                if (const err = audioStream.bind(media.audioOut.id))
                {
                    logger.error("Error audio stream binding to device");
                    return;
                }
            }
        }

        if (!audioBuffer.isEmpty && audioStream)
        {
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
        }

        updateVideo;
    }

    void updateVideo()
    {
        if (videoBuffer.isEmpty)
        {
            return;
        }

        if (!texture)
        {
            return;
        }

        import api.dm.gui.controls.video.video_decoder : UVFrame;

        videoBuffer.mutex.lock;
        scope (exit)
        {
            videoBuffer.mutex.unlock;
        }

        UVFrame vframe;
        const isPeek = videoBuffer.peek(vframe);
        if (!isPeek)
        {
            import std;

            debug writeln("Error peek videoframe from buffer: ", isPeek);
            return;
        }

        assert(isPeek);

        auto audioTime = audioTimeSec;
        auto videoTimeSec = vframe.ptsSec;

        double diffTime = videoTimeSec - audioTime;
        if (Math.abs(diffTime) > 0.5)
        {
            audioSamplesCount += cast(size_t)(diffTime * 48000);
        }

        //video ahead
        if (diffTime > 0.01)
        {
            return;
        }
        //video behind 
        else if (diffTime < -0.1)
        {
            const isRemove = videoBuffer.remove;
            assert(isRemove);
            if (isRemove != ContainerResult.success)
            {
                import std;

                writeln("Error removing videoframe from buffer: ", isRemove);
            }
            else
            {
                vframe.free;
            }
            return;
        }

        scope (exit)
        {
            const isRemove = videoBuffer.remove;
            if (isRemove != ContainerResult.success)
            {
                import std;

                writeln("Error removing videoframe from buffer: ", isRemove);
            }
            else
            {
                vframe.free;
            }
        }

        void* ptr;
        if (const err = texture.nativeTexture.nativePtr(ptr))
        {

        }

        auto tptr = cast(SDL_Texture*) ptr;
        assert(tptr);

        assert(vframe.yPlane.length > 0);
        assert(vframe.uPlane.length > 0);
        assert(vframe.vPlane.length > 0);

        SDL_UpdateYUVTexture(tptr, null,
            vframe.yPlane.ptr, cast(int) vframe.yPitch,
            vframe.uPlane.ptr, cast(int) vframe.uPitch,
            vframe.vPlane.ptr, cast(int) vframe.vPitch);
    }

    __gshared double audioTimeSec;
    __gshared ulong audioSamplesCount;

    void handleAudioData(SDL_AudioStream* stream, int additional_amount, int total_amount) nothrow @nogc
    {
        try
        {

            if (!audioBuffer.isEmpty)
            {
                audioBuffer.mutex.lock_nothrow;
                scope (exit)
                {
                    audioBuffer.mutex.unlock_nothrow;
                }

                if (!isRun)
                {
                    auto upSize = cast(size_t) audioBuffer.sizeLimit * 0.5;
                    if (audioBuffer.size < upSize)
                    {
                        return;
                    }
                    isRun = true;
                }

                auto newAmount = additional_amount * 16;
                auto available = SDL_GetAudioStreamAvailable(stream);
                if (available < newAmount && newAmount < audioBuffer.size)
                {
                    additional_amount = newAmount;
                }

                void updateClock() @nogc nothrow
                {
                    audioSamplesCount += additional_amount / (2 * float.sizeof);

                    size_t bytesPerSample = float.sizeof * 2;
                    auto queueBytes = SDL_GetAudioStreamQueued(stream);
                    double buffTime = cast(double) queueBytes / (48000 * bytesPerSample);
                    audioTimeSec = audioSamplesCount / 48000.0 - buffTime;
                }

                updateClock;

                //debug
                //{
                const isRead = audioBuffer.read((ubyte[] buff, ubyte[] rest) @safe {

                    () @trusted {

                        if (buff.length == 0)
                        {
                            return;
                        }

                        if (rest.length == 0)
                        {
                            SDL_PutAudioStreamData(stream, &buff[0], cast(int) buff.length);
                            return;
                        }
                        //TODO pool

                        import core.memory : pureMalloc, pureFree;

                        const elems = buff.length + rest.length;
                        auto fullBuffPtr = pureMalloc(
                            elems);
                        assert(fullBuffPtr);
                        auto fullBuff = fullBuffPtr[0 .. elems];

                        size_t index;
                        fullBuff[0 .. buff.length] = buff;
                        index += buff.length;
                        fullBuff[index .. (index + rest.length)] = rest;

                        SDL_PutAudioStreamData(stream, &fullBuff[0], cast(int) elems);
                        scope (exit)
                        {
                            pureFree(fullBuffPtr);
                        }
                    }();
                }, additional_amount);

                import api.core.utils.structs.container_result : ContainerResult;

                if (isRead != ContainerResult.success)
                {
                    import std;

                    debug writefln("Read %s bytes for audiodevice: %s. Size: %s, ri: %s, wi: %s", additional_amount, isRead, audioBuffer
                            .size, audioBuffer.readIndex, audioBuffer.writeIndex);
                }
            }
        }

        catch (Exception e)
        {
            import std.stdio : stderr, writeln;

            debug stderr.writeln("Error in audio callback: ", e);
        }
    }

    override void dispose()
    {
        super.dispose;

        if (demuxer && demuxer.isRunning)
        {
            demuxer.stop;
        }
    }

}
