module api.dm.addon.media.video.gui.video_player;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.back.sdl3.sounds.sdl_audio_stream : SdlAudioStream;
import api.dm.com.audio.com_audio_device : ComAudioSpec, ComAudioFormat;

import core.sync.mutex : Mutex;
import core.sync.condition : Condition;
import api.core.utils.queues.ring_buffer : RingBuffer;
import api.core.utils.container_result : ContainerResult;
import api.core.utils.sync : MutexLock;

import std.concurrency : spawn, send, receiveTimeout, Tid;
import core.thread.osthread : Thread;

import api.dm.addon.media.video.gui.media_demuxer : MediaDemuxer, DemuxerContext;
import api.dm.addon.media.video.gui.video_decoder : VideoDecoder;
import api.dm.addon.media.video.gui.audio_decoder : AudioDecoder;

import api.dm.addon.media.video.gui.video_decoder : VideoDecoder, UVFrame, VideoDecoderContext;
import api.dm.addon.media.video.gui.audio_decoder : AudioDecoder, AudioDecoderContext;

import api.dm.lib.ffmpeg.native;
import csdl;

import Math = api.math;

struct AudioDataCallback
{
    void delegate(SDL_AudioStream*, int, int) nothrow dg;
}

static extern (C) void streamCallback(void* userdata, SDL_AudioStream* stream, int additional_amount, int total_amount) nothrow
{
    AudioDataCallback* callbackData = cast(AudioDataCallback*) userdata;
    assert(callbackData);
    assert(callbackData.dg);
    callbackData.dg(stream, additional_amount, total_amount);
}

auto mediaPlayer(
    size_t VideoQueueSize = 40960,
    size_t AudioQueueSize = 40960,
    size_t VideoBufferSize = 200,
    size_t AudioBufferSize = 819200)(string path, float width = 200, float height = 200)
{

    return new VideoPlayer!(
        VideoQueueSize,
        AudioQueueSize,
        VideoBufferSize,
        AudioBufferSize)(path, width, height);
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

    MediaDemuxer!(
        VideoQueueSize,
        AudioQueueSize,
        VideoBufferSize,
        AudioBufferSize) demuxer;

    VideoDecoder!(VideoQueueSize, VideoBufferSize) videoDecoder;
    AudioDecoder!(AudioQueueSize, AudioBufferSize) audioDecoder;

    string path;

    this(string path, float width = 200, float height = 200)
    {
        initSize(width, height);
        isDrawBounds = true;

        assert(path.length > 0);
        this.path = path;
    }

    Texture2d texture;
    SdlAudioStream audioStream;

    protected
    {
        __gshared bool isRun;
    }

    AudioDataCallback audioDataCallback;

    protected
    {
        shared Mutex contextMutex;
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

        texture.lock;
        scope (exit)
        {
            texture.unlock;
        }

        import api.dm.kit.graphics.colors.rgba : RGBA;

        foreach (y; 0 .. (cast(uint) texture.height))
        {
            foreach (x; 0 .. (cast(uint)(texture.width)))
            {
                texture.changeColor(x, y, RGBA.red);
            }
        }
    }

    void load()
    {
        int windowWidth = cast(int) texture.width;
        int windowHeight = cast(int) texture.height;

        audioDataCallback = AudioDataCallback(&handleAudioData);

        videoPacketQueue = typeof(videoPacketQueue)(new shared Mutex);
        videoPacketQueue.initialize;
        audioPacketQueue = typeof(audioPacketQueue)(new shared Mutex);
        audioPacketQueue.initialize;

        videoBuffer = typeof(videoBuffer)(new shared Mutex);
        videoBuffer.isWriteForFill = true;
        videoBuffer.initialize;
        audioBuffer = typeof(audioBuffer)(new shared Mutex);
        audioBuffer.isWriteForFill = true;
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

        foreach (int i; 0 .. pFormatCtx.nb_streams)
        {
            auto stream = pFormatCtx.streams[i];

            AVCodecParameters* codecParam = stream.codecpar;
            AVCodec* codec = avcodec_find_decoder(codecParam.codec_id);
            if (codecParam.codec_type == AVMediaType.AVMEDIA_TYPE_VIDEO && !foundVideo)
            {
                //fmt_ctx.streams[i].discard = AVDISCARD_ALL;
                vidCodec = codec;
                vidpar = codecParam;
                vidId = i;

                videoTimeBase = stream.time_base;
                videoAvgRate = stream.avg_frame_rate;

                //fpsrendering = 1.0 / (cast(float) rational.num / cast(float)(rational.den));
                foundVideo = true;
            }
            else if (codecParam.codec_type == AVMediaType.AVMEDIA_TYPE_AUDIO && !foundAudio)
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

        logger.infof("Open media file, video %s, audio %s, target w:%s,h:%s", foundVideo, foundAudio, windowWidth, windowHeight);

        demuxer = new typeof(demuxer)(
            logger,
            DemuxerContext(contextMutex, foundVideo, foundAudio, windowWidth, windowHeight, pFormatCtx, vidId, audId),
            &videoPacketQueue,
            &audioPacketQueue,
            &videoBuffer,
            &audioBuffer,
        );

        videoDecoder = new typeof(videoDecoder)(
            logger,
            VideoDecoderContext(vidpar, vidCodec, windowWidth, windowHeight, videoTimeBase, videoAvgRate),
            &videoPacketQueue,
            &videoBuffer);

        audioDecoder = new typeof(audioDecoder)(
            logger,
            AudioDecoderContext(audCodec, audpar, media.audioOut.spec),
            &audioPacketQueue,
            &audioBuffer);

        videoDecoder.start;
        audioDecoder.start;

        demuxer.start;
    }

    override void update(float dt)
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

        import api.dm.addon.media.video.gui.video_decoder : UVFrame;

        videoBuffer.mutex.lock;
        scope (exit)
        {
            videoBuffer.mutex.unlock;
        }

        UVFrame vframe;
        const isPeek = videoBuffer.peek(vframe);
        if (!isPeek)
        {
            logger.errorf("Error peek videoframe from buffer: %s", isPeek);
            return;
        }

        auto audioTime = audioTimeSec;
        auto videoTimeSec = vframe.ptsSec;

        const syncThreshold = 0.1;
        const maxSyncThreshold = syncThreshold * 10;

        float diffTime = videoTimeSec - audioTime;
        if (Math.abs(diffTime) > maxSyncThreshold)
        {
            //logger.warningf("Video and audio out of sync by more than %s: %s", maxSyncThreshold, diffTime);
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
            videoBuffer.removeStrict;
            vframe.free;
            return;
        }

        scope (exit)
        {
            videoBuffer.removeStrict;
            vframe.free;
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

    __gshared float audioTimeSec;
    __gshared ulong audioSamplesCount;

    void handleAudioData(SDL_AudioStream* stream, int additional_amount, int total_amount) nothrow
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

                void updateClock() nothrow
                {
                    audioSamplesCount += additional_amount / (2 * float.sizeof);

                    size_t bytesPerSample = float.sizeof * 2;
                    auto queueBytes = SDL_GetAudioStreamQueued(stream);
                    float buffTime = cast(float) queueBytes / (44000 * bytesPerSample);
                    // float buffTime = 0;
                    audioTimeSec = audioSamplesCount / 44000.0 - buffTime;
                }

                updateClock;

                //debug
                //{
                const isRead = audioBuffer.read((scope ubyte[] buff, ubyte[] rest) @safe {

                    () @trusted {

                        if (buff.length == 0)
                        {
                            return;
                        }

                        if (rest.length == 0)
                        {
                            //TODO SDL_PutAudioStreamDataNoCopy
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

                import api.core.utils.container_result : ContainerResult;

                if (isRead != ContainerResult.success)
                {
                    debug {
                        import std.stdio: writefln;
                        
                        // writefln("Read %s bytes for audiodevice: %s. Size: %s, ri: %s, wi: %s", additional_amount, isRead, audioBuffer
                        //     .size, audioBuffer.readIndex, audioBuffer.writeIndex);
                    }
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
