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

    double function(double time, double freq, double phase) sampleFunc = &sinovertones;
    double delegate(double time, double freq, double phase) sampleProvider;

    invariant
    {
        assert(sampleRateHz > 0);
    }

    this(double sampleRateHz)
    {
        assert(sampleRateHz > 0);
        this.sampleRateHz = sampleRateHz;
    }

    void sound(T[] buffer, double freqHz = 0, double amplitude0to1 = 0.9, double phase = 0)
    {
        onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, frameTime, time) {
            //time = time / channels;
            auto sample = sampleProvider ? sampleProvider(frameTime, freqHz, phase) : sampleFunc(frameTime, freqHz, phase);
            sample *= adsr.adsr(time);
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

        sound(noteBuff.buffer, n.freqHz, amplitude0to1);

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

    struct FMPhase
    {
        double phase = 0;
        double phaseMod = 0;
    }

    private
    {
        FMPhase fmPhase;
    }

    /** 
     * Kick,fc:50–100Hz,fm:50–200Hz,i:5–15
     * Snare,fc:150–300Hz,fm:1–5kHz,i:10–30 + white noize
     * Hi-Hat,fc:200–1000Hz,fm:5–10kHz,i:20–50
     *  
     * flute,fc:500–2000Hz,fm:(0.5–1)*fc,i:1-3
     * oven,fc:200–800Hz,fm:(2-5)*fc,i:5-10
     * bell,fc:500–2000Hz,fm(1.414 (nonint,mult) × fc),i:10-50,
     * Moog,fc:50–150Hz,fm(0.5–2*fc),i:3-8
     * DX7,fc:100–200Hz,fm(3–5*fc),i:10–20
     */

    void sequence(FMdata[] notes, scope void delegate(T[], double) onScopeBufferTime, double bpm = 120, double amplitude0to1 = 0.9)
    {
        double fullTimeMs = 0;
        foreach (n; notes)
        {
            fullTimeMs += n.durationMs;
        }

        auto seqBuff = FiniteSignalBuffer!T(synt.sampleRateHz, fullTimeMs, synt.channels);
        scope (exit)
        {
            seqBuff.dispose;
        }

        size_t buffIndex = 0;

        //TODO reset phase
        //double phase = 0; if (phase >= 1.0) phase -= 1.0;

        import std.math : fmod;

        foreach (n; notes)
        {
            auto time = n.durationMs;
            auto noteBuff = FiniteSignalBuffer!T(synt.sampleRateHz, time, synt.channels);

            onBuffer(noteBuff.buffer, synt.sampleRateHz, amplitude0to1, synt.channels, (i, frameTime, fullTime) {
                auto sample = fmodulator(frameTime, 0, 0, n.fc, n.fm, n.index);
                sample *= synt.adsr.adsr(fullTime);
                return sample;
            });

            auto endIndex = buffIndex + noteBuff.buffer.length;
            seqBuff.buffer[buffIndex .. endIndex][] = noteBuff.buffer;

           

            buffIndex = endIndex;
            noteBuff.dispose;
        }

        //synt.fadeInOut(seqBuff.buffer);

        onScopeBufferTime(seqBuff.buffer, fullTimeMs);
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
