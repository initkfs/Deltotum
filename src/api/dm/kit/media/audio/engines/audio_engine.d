module api.dm.kit.media.audio.engines.audio_engine;

import api.dm.kit.media.audio.sounds.audio_mixer : AudioMixer;
import api.dm.kit.media.audio.devices.audio_stream : AudioStream;
import api.dm.kit.media.audio.sounds.sound : Sound, SoundHandle;
import api.core.utils.queues.ring_buffer_lf : RingBufferLF;
import api.dm.kit.media.audio.devices.audio_spec : AudioSpec;
import api.dm.kit.media.audio.chunks.audio_chunk : AudioChunk;

import core.thread.osthread : Thread;
import core.sync.mutex : Mutex;

/**
 * Authors: initkfs
 */

class AudioEngine : Thread
{
    AudioStream!(4096 * 2 * float.sizeof) buffer;
    AudioMixer mixer;

    float[] samples = new float[256 * 2];

    shared Mutex mixerMutex;

    this(AudioSpec spec)
    {
        mixerMutex = new shared Mutex;

        buffer = new typeof(buffer);
        buffer.spec = spec;
        buffer.create;
        mixer = new AudioMixer;
        super(&mix);
    }

    void mix()
    {
        while (true)
        {
            try
            {
                if (!mixer.isPlayingOrFree)
                {
                    // if (buffer.isOpen)
                    // {
                    //     buffer.stop;
                    // }
                    continue;
                }

                mixer.mix(samples, 2, true);
                if (!buffer.isOpen)
                {
                    buffer.open;
                }
                buffer.writeAudio(samples);
            }
            catch (Exception e)
            {
                import std.stdio : stderr, writeln;

                stderr.writeln(e);
            }
            catch (Throwable e)
            {
                import std.stdio : stderr, writeln;

                stderr.writeln(e);
                throw e;
            }
        }
    }

    bool isPlay(SoundHandle soundId)
    {
        mixerMutex.lock;
        scope (exit)
        {
            mixerMutex.unlock;
        }
        return mixer.isPlaying(soundId);
    }

    SoundHandle play(Sound sound)
    {
        mixerMutex.lock;
        scope (exit)
        {
            mixerMutex.unlock;
        }
        const sid = mixer.play(sound);
        return sid;
    }
}
