module api.dm.kit.media.audio.engines.audio_engine;

import api.dm.kit.media.audio.sounds.audio_mixer : AudioMixer;
import api.dm.kit.media.audio.streams.audio_stream : AudioStream;
import api.dm.kit.media.audio.mixers.mix_sound : MixSound, SoundHandle;
import api.core.utils.queues.ring_buffer_spsc : RingBuffer;
import api.dm.kit.media.audio.streams.audio_spec : AudioSpec;
import api.dm.kit.media.audio.chunks.audio_chunk : AudioChunk;
import api.dm.kit.media.dsp.dsp_processor : DspProcessor;
import core.atomic : atomicLoad, atomicStore;
import core.thread.osthread : Thread;
import core.sync.mutex : Mutex;

import Math = api.math;

/**
 * Authors: initkfs
 */

class AudioEngine : Thread
{
    double delegate() timestampMsProvider;

    enum AUDIO_QUEUE_SIZE_SEC = 5;

    //interval <= ideal callback interval 512 / 44100 = 0.01161 sec = 11.6 ms
    //enum MIX_INTERVAL_MS = 10;
    enum SAMPLE_RATE = 44100;
    enum CHANNELS = 2;
    enum FRAMES_PER_BUFFER = 2048;

    enum CallbackIntervalMs = (FRAMES_PER_BUFFER / (cast(float) SAMPLE_RATE)) * 1000.0;
    enum float MIX_INTERVAL_MS = CallbackIntervalMs * 0.95;

    enum AudioQueueSize = SAMPLE_RATE * AUDIO_QUEUE_SIZE_SEC * 2;

    __gshared AudioStream!(AudioQueueSize, FRAMES_PER_BUFFER, CHANNELS) buffer;
    __gshared AudioMixer mixer;

    //length % channels == 0
    __gshared float[] samples;

    shared Mutex mixerMutex;
    

    enum DspWindowSize = 2048;

    shared Mutex dspMutex;
    __gshared DspProcessor!(DspWindowSize * 100, 2, DspWindowSize) dspProcessor;

    __gshared double bufferStartTimeSec = 0;
    __gshared double lastMixTimeMs = 0;

    this(AudioSpec spec)
    {
        mixerMutex = new shared Mutex;

        buffer = new typeof(buffer);
        buffer.spec = spec;
        buffer.create;
        mixer = new AudioMixer;

        // const mixBufferFrames = Math.nextPowerOfTwo(cast(uint) Math.max(FRAMES_PER_BUFFER, (
        //         SAMPLE_RATE * MIX_INTERVAL_MS * 2 / 1000)));
        //samples = new float[](mixBufferFrames * 2);
        samples = new float[](FRAMES_PER_BUFFER * 2);
        samples[] = 0;

        dspProcessor = new typeof(dspProcessor)(dspMutex, SAMPLE_RATE, DspWindowSize);

        super(&mix);
    }

    void sleep()
    {
        import core.time : dur;

        Thread.sleep(dur!("msecs")(1));
        //Thread.yield;
    }

    double callbackPrevTimeSec = 0;

    void mix()
    {
        while (true)
        {
            try
            {
                //mixer.freeSounds;

                //if (!mixer.isPlaying && buffer.size == 0)
                //{
                // if (buffer.isStop)
                // {
                //     sleep;
                //     continue;
                // }

                // import std;

                // writeln("Stop audio stream");
                //buffer.stop;
                //sleep;
                //continue;
                //}

                auto nowMs = timestampMsProvider();
                auto elapsedMs = nowMs - atomicLoad(lastMixTimeMs);

                //auto streamTimeSec = buffer.streamTimeSec;

                if (elapsedMs >= MIX_INTERVAL_MS)
                {
                    auto mixSize = mixer.mix(samples, 2, true);
                    if (mixSize == 0)
                    {
                        //sleep;
                        continue;
                    }

                    if (!buffer.isStart)
                    {
                        buffer.start;
                        import std;

                        writeln("Start audio stream");
                        atomicStore(bufferStartTimeSec, buffer.streamTimeSec);
                    }

                    auto fillSlice = samples[0 .. mixSize];

                    auto size = buffer.writeAudio(fillSlice);
                    if (size != fillSlice.length)
                    {
                        //TODO log
                    }

                    if (dspProcessor)
                    {
                        //auto fftLen = mixSize % 2 != 0 ? Math.prevPowerOfTwo(
                        //    cast(uint) mixSize) : mixSize;
                        //if (fftLen > 0 && fftLen <= fillSlice.length)
                        //{
                        //dspProcessor.process(fillSlice[0 .. fftLen]);
                        dspProcessor.process(samples);
                        //}
                    }

                    atomicStore(lastMixTimeMs, timestampMsProvider());

                    //TODO correct from callback interval
                    //auto nowCallbackTime = atomicLoad(buffer.callbackTimeSec);
                    //auto el = nowCallbackTime - callbackPrevTimeSec;
                    //callbackPrevTimeSec = nowCallbackTime;  
                }
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

    double audioClock()
    {
        return atomicLoad(buffer.frameClock);
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

    void play(MixSound[] MixSound)
    {
        mixerMutex.lock;
        scope (exit)
        {
            mixerMutex.unlock;
        }

        foreach (s; MixSound)
        {
            mixer.play(s);
        }
    }

    size_t writeAudio(float[] samples)
    {
        if (!buffer.isStart)
        {
            buffer.start;
        }
        return buffer.writeAudio(samples);
    }

    SoundHandle play(MixSound MixSound)
    {
        mixerMutex.lock;
        scope (exit)
        {
            mixerMutex.unlock;
        }
        const sid = mixer.play(MixSound);
        return sid;
    }
}
