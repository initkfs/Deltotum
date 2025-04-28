module api.dm.gui.controls.video.video_player;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.back.sdl3.sounds.sdl_audio_stream : SdlAudioStream;
import api.dm.com.audio.com_audio_device : ComAudioSpec, ComAudioFormat;

import core.sync.mutex : Mutex;
import core.sync.condition : Condition;
import api.core.utils.structs.rings.ring_buffer : RingBuffer;
import api.core.utils.sync : MutexLock;

import std.concurrency : spawn, send, receiveTimeout, Tid;
import core.thread.osthread : Thread;

import api.dm.gui.controls.video.player_demuxer : PlayerDemuxer;
import api.dm.gui.controls.video.video_decoder : VideoDecoder;
import api.dm.gui.controls.video.audio_decoder : AudioDecoder;

import cffmpeg;
import csdl;

import Math = api.math;

static extern (C) void streamCallback(void* userdata, SDL_AudioStream* stream, int additional_amount, int total_amount) nothrow @nogc
{
    VideoPlayer player = cast(VideoPlayer) userdata;
    assert(player);
    if (!player.demuxer.audioDecoder.buffer.isEmpty)
    {
        debug
        {
            const isRead = player.demuxer.audioDecoder.buffer.readSync((ubyte[] buff, ubyte[] rest) @safe {
                () @trusted {
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
            // import std;

            // debug writefln("Send %s bytes to audio %s, size: %s, ri: %s, wi: %s", additional_amount, isRead, player.demuxer.audioDecoder.buffer.size, player
            //         .demuxer.audioDecoder.buffer.readIndex, player.demuxer
            //         .audioDecoder.buffer.writeIndex);
        }
    }
}

/**
 * Authors: initkfs
 */
class VideoPlayer : Control
{
    PlayerDemuxer!(10, 2048, 2048, 81920) demuxer;

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

        demuxer = new typeof(demuxer)(logger, "/home/user/sdl-music/sw.wmv", cast(int) texture.width, cast(
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

        if (!audioDecoder.buffer.isEmpty && audioStream)
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
