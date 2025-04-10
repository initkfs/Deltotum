module api.dm.kit.media.synthesis.synthesizers.sound_synthesizer;

import api.dm.kit.media.dsp.buffers.finite_signal_buffer;
import api.dm.kit.media.synthesis.music_notes;
import api.dm.kit.media.synthesis.effect_synthesis;
import api.dm.kit.media.synthesis.signal_synthesis;

import Math = api.math;

/**
 * Authors: initkfs
 */

class SoundSynthesizer(T)
{
    double noteTimeMs(double bpm, NoteType noteType, double minDurMs = 50)
    {
        auto dur = (60.0 / bpm) * (4.0 / noteType) * 1000;
        if (dur < minDurMs)
        {
            dur = minDurMs;
        }
        return dur;
    }

    unittest
    {
        import std.math.operations : isClose;

        assert(isClose(noteTime(120, NoteType.note1_8), 500));
        assert(isClose(noteTime(60, NoteType.note1_16), 125));
    }

    void sequence(MusicNote[] notes, double sampleRate, scope void delegate(T[], double) onScopeBufferTime, double bpm = 120, size_t channels = 2)
    {
        double fullTimeMs = 0;
        foreach (n; notes)
        {
            fullTimeMs += noteTimeMs(bpm, n.type);
        }

        auto seqBuff = FiniteSignalBuffer!T(sampleRate, fullTimeMs, channels);
        scope (exit)
        {
            seqBuff.dispose;
        }

        size_t buffIndex = 0;

        int overlap = 50;

        //TODO reset phase
        //double phase = 0; if (phase >= 1.0) phase -= 1.0;

        double phase = 0.0;

        import std.math : fmod;

        foreach (n; notes)
        {
            auto time = noteTimeMs(bpm, n.type);
            auto noteBuff = FiniteSignalBuffer!T(sampleRate, time, channels);

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

            note(noteBuff.buffer, n.freqHz, phase, time, prevAmp, sampleRate, 0.9, channels);
            auto endIndex = buffIndex + noteBuff.buffer.length;
            seqBuff.buffer[buffIndex .. endIndex][] = noteBuff.buffer;

            phase = fmod(Math.PI2 * n.freqHz * (noteBuff.buffer.length / sampleRate) + phase, Math
                    .PI2);

            //crossfade
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

        //≥10 мс
        size_t samples = cast(size_t)(10.0 / 1000 * sampleRate);
        fadein(seqBuff.buffer, samples, channels);
        fadeout(seqBuff.buffer, samples, channels);

        onScopeBufferTime(seqBuff.buffer, fullTimeMs);
    }

    void noteOnce(MusicNote n, double sampleRateHz, scope void delegate(T[], double) onScopeBufferTime, double bpm = 120, double amplitude0to1 = 0.9, size_t channels = 2)
    {
        auto time = noteTimeMs(bpm, n.type);
        auto noteBuff = FiniteSignalBuffer!T(sampleRateHz, time, channels);
        scope (exit)
        {
            noteBuff.dispose;
        }

        note(noteBuff.buffer, n.freqHz, 0, time, 0, sampleRateHz, amplitude0to1, channels);

        //≥10 мс
        size_t samples = cast(size_t)(10.0 / 1000 * sampleRateHz);
        fadein(noteBuff.buffer, samples, channels);
        fadeout(noteBuff.buffer, samples, channels);

        onScopeBufferTime(noteBuff.buffer, time);
    }

    void note(T)(T[] buffer, double freqNoteHz, double phase, double durationMs, double prevAmp, double sampleRateHz, double amplitude0to1 = 0.9, size_t channels = 2)
    {
        onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
            //durationMs / 1000;* adsr(time, durationMs)
            auto sample = overtones(time, freqNoteHz, phase) * adsr(time);
            return sample;
        });
    }
}

struct Drum
{
    ADSR adsr;

    void drum(T)(T[] buffer, double sampleRateHz, double amplitude0to1 = 0.9, size_t channels = 2)
    {
        onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
            if (i % 4 == 0)
            {
                return kick(time, 0.1) * adsr.adsr(time);
            }
            return 0.0;
        });
    }
}

double sine(double phase)
{
    return Math.sin(phase * Math.PI2);
}

double kick(double time, double duration)
{
    import std.math : exp;

    double freq = 50.0 * exp(-time * 5.0);
    double modulator = sine(time * 200.0) * 0.5;
    double carrier = sine(time * freq + modulator);
    double envelope = exp(-time * 10.0);
    return carrier * envelope;
}
