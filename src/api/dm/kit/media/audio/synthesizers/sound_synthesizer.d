module api.dm.kit.media.audio.synthesizers.sound_synthesizer;

import api.dm.kit.media.audio.synthesizers.base_synthesizer : BaseSynthesizer;
import api.dm.kit.media.audio.chunks.audio_chunk;
import api.dm.kit.media.audio.music.music_notes;
import api.dm.kit.media.dsp.synthesis.effect_synthesis;
import api.dm.kit.media.dsp.synthesis.signal_synthesis;

import api.dm.kit.media.dsp.analog_signals;

import Math = api.math;

/**
 * Authors: initkfs
 */

class SoundSynthesizer : BaseSynthesizer
{
    this(float sampleRateHz)
    {
        super(sampleRateHz);
    }

    void note(MusicNote n, float amplitude0to1, float[] delegate(float) bufferOnTimeProvider)
    {
        note(n, amplitude0to1, (scopeBuff, time) {
            float[] outBuff = bufferOnTimeProvider(time);
            if (outBuff.length != scopeBuff.length)
            {
                import std.format : format;

                throw new Exception(format("Src buffer len: %s, target %s", scopeBuff.length, outBuff
                    .length));
            }
            outBuff[] = scopeBuff;
        });
    }

    void note(MusicNote n, float amplitude0to1, scope void delegate(float[], float) onScopeBufferTime)
    {
        auto time = n.durationMs;
        auto noteBuff = AudioChunk(sampleRateHz, time, channels);
        scope (exit)
        {
            noteBuff.dispose;
        }

        MixSound(noteBuff.buffer, n.freqHz, amplitude0to1);

        if (isFadeInOut)
        {
            fadeInOut(noteBuff.buffer);
        }

        onScopeBufferTime(noteBuff.buffer, time);
    }

    AudioChunk* noteNew(MusicNote n, float amplitude0to1)
    {
        auto time = n.durationMs;
        auto noteBuff = new AudioChunk(sampleRateHz, time, channels);
        MixSound(noteBuff.buffer, n.freqHz, amplitude0to1);

        if (isFadeInOut)
        {
            fadeInOut(noteBuff.buffer);
        }

        return noteBuff;
    }

    void sequence(MusicNote[] notes, float amplitude0to1, float[]delegate(float) bufferOnTimeProvider)
    {
        sequence(notes, amplitude0to1, (scopeBuff, time) {
            float[] outBuff = bufferOnTimeProvider(time);
            if (outBuff.length != scopeBuff.length)
            {
                import std.format : format;

                throw new Exception(format("Sequence src buffer len: %s, target %s", scopeBuff.length, outBuff
                    .length));
            }
            outBuff[] = scopeBuff;
        });
    }

    void sequence(MusicNote[] notes, float amplitude0to1, scope void delegate(float[], float) onScopeBufferTime)
    {
        assert(notes.length > 0);

        float fullTimeMs = 0;
        foreach (n; notes)
        {
            fullTimeMs += n.durationMs;
        }

        auto seqBuff = AudioChunk(sampleRateHz, fullTimeMs, channels);
        scope (exit)
        {
            seqBuff.dispose;
        }

        size_t buffIndex = 0;

        //TODO reset phase
        //float phase = 0; if (phase >= 1.0) phase -= 1.0;

        float phase = 0.0;

        import std.math : fmod;

        foreach (n; notes)
        {
            auto time = n.durationMs;
            auto noteBuff = AudioChunk(sampleRateHz, time, channels);
            scope(exit){
                noteBuff.dispose;
            }

            // float prevAmp = 0;
            // size_t maxLastSamples = 50;
            // if (buffIndex > 0 && buffIndex >= maxLastSamples)
            // {
            //     foreach_reverse (i; (buffIndex - maxLastSamples) .. buffIndex)
            //     {
            //         auto val = seqBuff.buffer[i];
            //         if (val != 0)
            //         {
            //             prevAmp = ((cast(float) val) / T.max);
            //             break;
            //         }
            //     }
            // }

            MixSound(noteBuff.buffer, n.freqHz, amplitude0to1, phase);

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

            //         float ratio = (cast(float) i) / overlap;
            //         float overval = seqBuff.buffer[ovIndex] * (1.0 - ratio) + noteBuff.buffer[i] * ratio;
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
