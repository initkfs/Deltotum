module api.dm.kit.media.synthesis.sound_synthesis;

import api.dm.kit.media.dsp.buffers.finite_signal_buffer;
import api.dm.kit.media.synthesis.music_notes;
import api.dm.kit.media.synthesis.effect_synthesis;
import api.dm.kit.media.synthesis.signal_synthesis;

import Math = api.math;

/**
 * Authors: initkfs
 */

struct SoundSynthesizer(T)
{
    double sampleRateHz = 0;
    size_t channels = 2;

    bool isFadeInOut = true;

    ADSR adsr;

    this(double sampleRateHz)
    {
        assert(sampleRateHz > 0);
        this.sampleRateHz = sampleRateHz;
    }

    invariant
    {
        assert(sampleRateHz > 0);
    }

    double function(double time, double freq, double phase) sampleProvider = &sinovertones;

    void sound(T[] buffer, double freqHz, double amplitude0to1 = 0.9, double phase = 0)
    {
        onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
            auto sample = sampleProvider(time, freqHz, phase) * adsr.adsr(time);
            return sample;
        });
    }

    void note(MusicNote n, scope void delegate(T[], double) onScopeBufferTime, double bpm = 120, double amplitude0to1 = 0.9)
    {
        auto time = noteTimeMs(bpm, n.type);
        auto noteBuff = FiniteSignalBuffer!T(sampleRateHz, time, channels);
        scope (exit)
        {
            noteBuff.dispose;
        }

        sound(noteBuff.buffer, n.freqHz, amplitude0to1, 0);

        if (isFadeInOut)
        {
            fadeInOut(noteBuff.buffer);
        }

        onScopeBufferTime(noteBuff.buffer, time);
    }

    void sequence(MusicNote[] notes, scope void delegate(T[], double) onScopeBufferTime, double bpm = 120, double amplitude0to1 = 0.9)
    {
        double fullTimeMs = 0;
        foreach (n; notes)
        {
            fullTimeMs += noteTimeMs(bpm, n.type);
        }

        auto seqBuff = FiniteSignalBuffer!T(sampleRateHz, fullTimeMs, channels);
        scope (exit)
        {
            seqBuff.dispose;
        }

        size_t buffIndex = 0;

        //TODO reset phase
        //double phase = 0; if (phase >= 1.0) phase -= 1.0;

        double phase = 0.0;

        import std.math : fmod;

        foreach (n; notes)
        {
            auto time = noteTimeMs(bpm, n.type);
            auto noteBuff = FiniteSignalBuffer!T(sampleRateHz, time, channels);

            double prevAmp = 0;
            size_t maxLastSamples = 50;
            if (buffIndex > 0 && buffIndex >= maxLastSamples)
            {
                foreach_reverse (i; (buffIndex - maxLastSamples) .. buffIndex)
                {
                    auto val = seqBuff.buffer[i];
                    if (val != 0)
                    {
                        prevAmp = ((cast(double) val) / T.max);
                        break;
                    }
                }
            }

            sound(noteBuff.buffer, n.freqHz, amplitude0to1, phase);

            auto endIndex = buffIndex + noteBuff.buffer.length;
            seqBuff.buffer[buffIndex .. endIndex][] = noteBuff.buffer;

            phase = fmod(Math.PI2 * n.freqHz * (noteBuff.buffer.length / sampleRateHz) + phase, Math
                    .PI2);

            //crossfade
            //int overlap = 50;
            // if (buffIndex > 0 && buffIndex > overlap / 2)
            // {
            //     auto ovIndex = buffIndex - overlap / 2;
            //     foreach (i; 0 .. overlap)
            //     {
            //         if (ovIndex >= seqBuff.buffer.length || i >= noteBuff.buffer.length)
            //         {
            //             break;
            //         }

            //         double ratio = (cast(double) i) / overlap;
            //         double overval = seqBuff.buffer[ovIndex] * (1.0 - ratio) + noteBuff.buffer[i] * ratio;
            //         seqBuff.buffer[ovIndex] = cast(T)(overval);
            //         ovIndex++;
            //     }
            // }

            buffIndex = endIndex;
            noteBuff.dispose;
        }

        if (isFadeInOut)
        {
            fadeInOut(seqBuff.buffer);
        }

        onScopeBufferTime(seqBuff.buffer, fullTimeMs);
    }

    void fadeInOut(T[] buffer)
    {
        //≥10 мс
        size_t samples = cast(size_t)(10.0 / 1000 * sampleRateHz);
        fadein(buffer, samples, channels);
        fadeout(buffer, samples, channels);
    }
}

struct DrumSynthesizer(T)
{
    SoundSynthesizer!T synt;

    this(double sampleRateHz)
    {
        synt = SoundSynthesizer!T(sampleRateHz);
    }
}

// double sine(double phase)
// {
//     return Math.sin(phase * Math.PI2);
// }

// double kick(double time, double duration)
// {
//     import std.math : exp;

//     double freq = 50.0 * exp(-time * 5.0);
//     double modulator = sine(time * 200.0) * 0.5;
//     double carrier = sine(time * freq + modulator);
//     double envelope = exp(-time * 10.0);
//     return carrier * envelope;
// }

// ADSR adsr;

// void drum(T)(T[] buffer, double sampleRateHz, double amplitude0to1 = 0.9, size_t channels = 2)
// {
//     onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
//         if (i % 4 == 0)
//         {
//             return kick(time, 0.1) * adsr.adsr(time);
//         }
//         return 0.0;
//     });
// }
