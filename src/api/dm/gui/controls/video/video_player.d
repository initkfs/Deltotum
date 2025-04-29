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

import cffmpeg;
import csdl;

import Math = api.math;

__gshared bool isRun;

static extern (C) void streamCallback(void* userdata, SDL_AudioStream* stream, int additional_amount, int total_amount) nothrow @nogc
{
    VideoPlayer player = cast(VideoPlayer) userdata;
    assert(player);
    if (!player.demuxer.audioDecoder.buffer.isEmpty)
    {
        if (!isRun)
        {
            auto upSize = cast(size_t) player.demuxer.audioDecoder.buffer.sizeLimit * 0.8;
            if (player.demuxer.audioDecoder.buffer.size < upSize)
            {
                return;
            }
            isRun = true;
            import std;

            debug writeln("Wait buffer. Set run");
        }

        debug
        {
            const isRead = player.demuxer.audioDecoder.buffer.readSync((ubyte[] buff, ubyte[] rest) @safe {
                () @trusted {
                    
                    if(buff.length == 0){
                        return;
                    }
                    
                    if (rest.length == 0)
                    {
                        SDL_PutAudioStreamData(stream, buff.ptr, cast(int) buff.length);
                    }
                    else
                    {
                        //TODO pool
                        import core.memory : pureMalloc, pureFree;

                        const elems = buff.length + rest.length;
                        auto fullBuffPtr = pureMalloc(elems);
                        assert(fullBuffPtr);
                        auto fullBuff = fullBuffPtr[0 .. elems];

                        size_t index;
                        fullBuff[0 .. buff.length] = buff;
                        index += buff.length;

                        fullBuff[index .. (index + rest.length)] = rest;

                        SDL_PutAudioStreamData(stream, fullBuff.ptr, cast(int) elems);

                        scope (exit)
                        {
                            pureFree(fullBuffPtr);
                        }
                    }
                }();

            }, additional_amount);

            import api.core.utils.structs.container_result : ContainerResult;

            if (isRead != ContainerResult.success)
            {
                // import std;

                // debug writefln("Read %s bytes for audiodevice: %s. Size: %s, ri: %s, wi: %s", additional_amount, isRead, player.demuxer.audioDecoder.buffer.size, player
                //         .demuxer.audioDecoder.buffer.readIndex, player.demuxer
                //         .audioDecoder.buffer.writeIndex);
            }
        }
    }
}

/**
 * Authors: initkfs
 */
class VideoPlayer : Control
{
    PlayerDemuxer!(8192, 40960, 8192, 1638400) demuxer;

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

    override void create()
    {
        super.create;

        texture = new Texture2d(width, height);
        addCreate(texture);
        texture.createMutYV;

        demuxer = new typeof(demuxer)(logger, "/home/user/sdl-music/WING_IT.mp4", cast(
                int) texture.width, cast(
                int) texture.height, media.audioOut.spec);

        demuxer.start;

        lastAudioUpdate = SDL_GetTicks();
    }

    override void update(double dt)
    {
        super.update(dt);

        if (!demuxer.isRunning || !demuxer.audioDecoder)
        {
            return;
        }

        if (!audioStream)
        {
            audioStream = new SdlAudioStream(demuxer.audioDecoder.srcSpec, media.audioOut.spec);
            if (const err = audioStream.setPutCallback(&streamCallback, cast(void*) this))
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

        auto audioDecoder = demuxer.audioDecoder;

        if (audioDecoder.isRunning && !audioDecoder.buffer.isEmpty && audioStream)
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
            //     else
            //     {
            //         const isRead = audioDecoder.buffer.readSync((ubyte[] buff, count) @safe {
            //             () @trusted {
            //                 const isPut = audioStream.putData(buff.ptr, count);
            //             }();
            //             //import std;

            //             //debug writefln("Send %s bytes to audio %s", alignedBytesFrame, isPut);
            //         }, alignedBytesFrame);
            //         import std;

            //         debug writefln("Read from audio buffer %s bytes: %s", alignedBytesFrame, isRead);
            //     }

            //     lastAudioUpdate = now;
            // }
        }

        auto videoDecoder = demuxer.videoDecoder;

        if (texture && videoDecoder.isRunning && !videoDecoder.buffer.isEmpty)
        {
            import api.dm.gui.controls.video.video_decoder : UVFrame;

            UVFrame vframe;
            const isReadUv = videoDecoder.buffer.readSync(vframe);
            if (isReadUv != ContainerResult.success)
            {
                import std;

                debug writeln("Error read videoframe from buffer: ", isReadUv);
            }else {

                scope(exit){
                    vframe.free;
                }

                void* ptr;
                if(const err = texture.nativeTexture.nativePtr(ptr)){

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
