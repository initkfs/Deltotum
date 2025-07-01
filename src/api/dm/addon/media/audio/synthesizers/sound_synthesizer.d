module api.dm.addon.media.audio.synthesizers.sound_synthesizer;

import api.dm.addon.media.audio.synthesizers.base_synthesizer : BaseSynthesizer;
import api.dm.kit.media.buffers.finite_signal_buffer;
import api.dm.addon.media.audio.music_notes;
import api.dm.addon.dsp.synthesis.effect_synthesis;
import api.dm.addon.dsp.synthesis.signal_synthesis;

import api.dm.addon.dsp.signal_funcs;

import Math = api.math;

/**
 * Authors: initkfs
 */

class SoundSynthesizer(T) : BaseSynthesizer!T
{
    this(double sampleRateHz)
    {
        super(sampleRateHz);
    }

    void note(MusicNote n, double amplitude0to1, T[]delegate(double) bufferOnTimeProvider)
    {
        note(n, amplitude0to1, (scopeBuff, time) {
            T[] outBuff = bufferOnTimeProvider(time);
            if (outBuff.length != scopeBuff.length)
            {
                import std.format : format;

                throw new Exception(format("Src buffer len: %s, target %s", scopeBuff.length, outBuff
                    .length));
            }
            outBuff[] = scopeBuff;
        });
    }

    void note(MusicNote n, double amplitude0to1, scope void delegate(T[], double) onScopeBufferTime)
    {
        auto time = n.durationMs;
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

    void sequence(MusicNote[] notes, double amplitude0to1, T[]delegate(double) bufferOnTimeProvider)
    {
        sequence(notes, amplitude0to1, (scopeBuff, time) {
            T[] outBuff = bufferOnTimeProvider(time);
            if (outBuff.length != scopeBuff.length)
            {
                import std.format : format;

                throw new Exception(format("Sequence src buffer len: %s, target %s", scopeBuff.length, outBuff
                    .length));
            }
            outBuff[] = scopeBuff;
        });
    }

    void sequence(MusicNote[] notes, double amplitude0to1, scope void delegate(T[], double) onScopeBufferTime)
    {
        assert(notes.length > 0);

        double fullTimeMs = 0;
        foreach (n; notes)
        {
            fullTimeMs += n.durationMs;
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
            auto time = n.durationMs;
            auto noteBuff = FiniteSignalBuffer!T(sampleRateHz, time, channels);

            // double prevAmp = 0;
            // size_t maxLastSamples = 50;
            // if (buffIndex > 0 && buffIndex >= maxLastSamples)
            // {
            //     foreach_reverse (i; (buffIndex - maxLastSamples) .. buffIndex)
            //     {
            //         auto val = seqBuff.buffer[i];
            //         if (val != 0)
            //         {
            //             prevAmp = ((cast(double) val) / T.max);
            //             break;
            //         }
            //     }
            // }

            sound(noteBuff.buffer, n.freqHz, amplitude0to1, phase);

            auto endIndex = buffIndex + noteBuff.buffer.length;
            seqBuff.buffer[buffIndex .. endIndex][] = noteBuff.buffer;

            // phase = fmod(Math.PI2 * n.freqHz * (noteBuff.buffer.length / sampleRateHz) + phase, Math
            //         .PI2);

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
}
