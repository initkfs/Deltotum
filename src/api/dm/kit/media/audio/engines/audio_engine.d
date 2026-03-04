module api.dm.kit.media.audio.engines.audio_engine;

import api.dm.kit.media.audio.sounds.audio_mixer : AudioMixer;
import api.dm.kit.media.audio.devices.audio_stream : AudioStream;
import api.dm.kit.media.audio.sounds.sound : Sound, SoundHandle;
import api.core.utils.queues.ring_buffer_lf : RingBufferLF;
import api.dm.kit.media.audio.devices.audio_spec : AudioSpec;
import api.dm.kit.media.audio.chunks.audio_chunk : AudioChunk;

import core.thread.osthread : Thread;
import core.sync.mutex : Mutex;

import Math = api.math;

/**
 * Authors: initkfs
 */
/**  
	  frames	mixBuffer	ringBuffer	ringBuffer (ms)
2 ms	88	       256	      2048	      46 ms
5 ms	220	       512	      4096	      93 ms
10 ms	441	       512	      8192	      186 ms
15 ms	661	       1024	      16384	      372 ms
 */
class AudioEngine : Thread
{
    enum AUDIO_QUEUE_SIZE_SEC = 5;

    //interval <= ideal callback interval 512 / 44100 = 0.01161 sec = 11.6 ms
    //enum MIX_INTERVAL_MS = 10;
    enum SAMPLE_RATE = 44100;
    enum CHANNELS = 2;
    enum FRAMES_PER_BUFFER = 1024;

    enum CallbackIntervalMs = (FRAMES_PER_BUFFER / (cast(float) SAMPLE_RATE)) * 1000.0;
    enum float MIX_INTERVAL_MS = CallbackIntervalMs * 0.85;

    enum AudioQueueSize = SAMPLE_RATE * AUDIO_QUEUE_SIZE_SEC * 2;

    AudioStream!(AudioQueueSize, FRAMES_PER_BUFFER, CHANNELS) buffer;
    AudioMixer mixer;

    //length % channels == 0
    __gshared float[] samples;

    shared Mutex mixerMutex;
    private double lastMixTimeMs;

    this(AudioSpec spec)
    {
        mixerMutex = new shared Mutex;

        buffer = new typeof(buffer);
        buffer.spec = spec;
        buffer.create;
        mixer = new AudioMixer;

        const mixBufferFrames = Math.nextPowerOfTwo(cast(uint) Math.max(FRAMES_PER_BUFFER, (
                SAMPLE_RATE * MIX_INTERVAL_MS * 2 / 1000)));
        samples = new float[](mixBufferFrames * 2);
        samples[] = 0;

        lastMixTimeMs = getCurrentTimeMs;

        super(&mix);
    }

    void sleep()
    {
        import core.time : dur;

        Thread.sleep(dur!("msecs")(1));
        //Thread.yield;
    }

    void mix()
    {
        while (true)
        {
            try
            {
                //mixer.freeSounds;

                if (!mixer.isPlaying && buffer.size == 0)
                {
                    if (buffer.isStop)
                    {
                        sleep;
                        continue;
                    }

                    import std;

                    writeln("Stop audio stream");
                    buffer.stop;
                    sleep;
                    continue;
                }

                auto nowMs = getCurrentTimeMs;
                auto elapsedMs = nowMs - lastMixTimeMs;

                if (elapsedMs >= MIX_INTERVAL_MS)
                {
                    lastMixTimeMs += MIX_INTERVAL_MS;

                    // if (nowMs - lastMixTimeMs > MIX_INTERVAL_MS)
                    // {
                    //     lastMixTimeMs = nowMs;
                    // }

                    auto mixSize = mixer.mix(samples, 2, true);
                    if (mixSize == 0)
                    {
                        sleep;
                        continue;
                    }

                    if (!buffer.isStart)
                    {
                        buffer.start;
                        import std;

                        writeln("Start audio stream");
                    }

                    auto fillSlice = samples[0 .. mixSize];

                    auto size = buffer.writeAudio(fillSlice);
                    if (size != fillSlice.length)
                    {
                        //TODO log
                    }
                }
                else
                {
                    sleep;
                }

                // auto mixSize = mixer.mix(samples, 2, true);
                // if (mixSize == 0)
                // {
                //     continue;
                // }

                // if (!buffer.isOpen)
                // {
                //     buffer.open;
                // }

                // auto fillSlice = samples[0 .. mixSize];

                // auto size = buffer.writeAudio(fillSlice);
                // if (size != fillSlice.length)
                // {
                //     isSend = false;
                //     continue;
                // }
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

    void play(Sound[] sound)
    {
        mixerMutex.lock;
        scope (exit)
        {
            mixerMutex.unlock;
        }

        foreach (s; sound)
        {
            mixer.play(s);
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

    private long getCurrentTimeMs()
    {
        import std.datetime.systime : Clock;

        return Clock.currTime.toUnixTime * 1000;
    }
}
