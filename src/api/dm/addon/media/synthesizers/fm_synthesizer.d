module api.dm.addon.media.synthesizers.fm_synthesizer;

import api.dm.addon.media.synthesizers.sound_synthesizer : SoundSynthesizer;
import api.dm.kit.media.buffers.finite_signal_buffer;
import api.dm.addon.media.music_notes;
import api.dm.addon.media.dsp.synthesis.effect_synthesis;
import api.dm.addon.media.dsp.synthesis.signal_synthesis;

import api.dm.addon.media.dsp.signal_funcs;

import Math = api.math;

/**
 * Authors: initkfs
 */
/** 
     * fc = 20...20000Khz, fm = 0.1 * fc.. 10 * fc
     * fm = fc * 15
     *
     * Kick,fc:50–100Hz,fm:50–200Hz,i:5–15
     * Snare,fc:150–300Hz,fm:1–5kHz,i:10–30 + white noize
     * Hi-Hat,fc:200–1000Hz,fm:5–10kHz,i:20–50
     *  
     * flute,fc:500–2000Hz,fm:(0.5–1)*fc,i:1-3
     * oven,fc:200–800Hz,fm:(2-5)*fc,i:5-10
     * bell,fc:500–2000Hz,fm(1.414 (nonint,mult) × fc),i:10-50,
     * Moog,fc:50–150Hz,fm(0.5–2*fc),i:3-8
     * DX7,fc:100–200Hz,fm(3–5*fc),i:10–20

     * quack, 11,69.90, adsr(0,4;0.1,0.6,0.4)
     * bell, fc*8, 1
     */
class FMSynthesizer(T) : SoundSynthesizer!T
{
    double fm = 0;
    double index = 0;
    bool isFcMulFm;

    this(double sampleRateHz)
    {
        super(sampleRateHz);
        sampleProvider = (double time, double freq, double phase) {

            auto targetFm = fm;
            if (isFcMulFm)
            {
                targetFm = freq * targetFm;
            }

            return fmodulator(time, phase, freq, targetFm, index);
        };
    }

    void sequence(FMdata[] notes, double amplitude0to1, T[]delegate(double) bufferOnTimeProvider)
    {
        sequence(notes, amplitude0to1, (scopeBuff, time) {
            T[] outBuff = bufferOnTimeProvider(time);
            if (outBuff.length != scopeBuff.length)
            {
                import std.format : format;

                throw new Exception(format("FM sequence src buffer len: %s, target %s", scopeBuff.length, outBuff
                    .length));
            }
            outBuff[] = scopeBuff;
        });
    }

    void sequence(FMdata[] notes, double amplitude0to1, scope void delegate(T[], double) onScopeBufferTime)
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

        import std.math : fmod;

        foreach (n; notes)
        {
            auto time = n.durationMs;
            auto noteBuff = FiniteSignalBuffer!T(sampleRateHz, time, channels);

            auto targetFm = n.fm;
            if (n.isFcMulFm)
            {
                targetFm = n.fc * targetFm;
            }

            onBuffer(noteBuff.buffer, sampleRateHz, amplitude0to1, channels, (i, frameTime, time) {
                auto sample = fmodulator(frameTime, 0, n.fc, targetFm, n.index);
                sample *= amplitude0to1;
                sample *= adsr.adsr(time);
                return sample;
            });

            auto endIndex = buffIndex + noteBuff.buffer.length;
            seqBuff.buffer[buffIndex .. endIndex][] = noteBuff.buffer;

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
