module api.dm.kit.media.audio.players.audio_engine;

import api.dm.kit.media.audio.mixers.audio_mixer : AudioMixer;
import api.dm.kit.media.buffers.audio_buffer : AudioBuffer;
import api.dm.kit.media.audio.mixers.sound : Sound, SoundHandle;
import api.core.utils.queues.ring_buffer_lf : RingBufferLF;
import api.dm.kit.media.audio.devices.audio_spec: AudioSpec;

import core.thread.osthread : Thread;
import core.sync.mutex : Mutex;

/**
 * Authors: initkfs
 */

class AudioEngine : Thread
{
    AudioBuffer!(4096 * 2 * float.sizeof) buffer;
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
                if (!mixer.isPlaying)
                {
                    continue;
                }

                mixerMutex.lock;
                scope (exit)
                {
                    mixerMutex.unlock;
                }

                mixer.mix(samples, 2, true);
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
