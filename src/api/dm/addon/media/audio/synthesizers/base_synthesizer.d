module api.dm.addon.media.audio.synthesizers.base_synthesizer;

import api.dm.kit.media.buffers.finite_signal_buffer;
import api.dm.addon.dsp.synthesis.effect_synthesis;
import api.dm.addon.dsp.synthesis.signal_synthesis;

import api.dm.addon.dsp.signal_funcs;

import Math = api.math;

/**
 * Authors: initkfs
 */

class BaseSynthesizer(T)
{
    float sampleRateHz = 0;
    size_t channels = 2;

    bool isFadeInOut = true;

    ADSR adsr;

    float function(float time, float freq, float phase) sampleFunc = &sinovertones;
    float delegate(float time, float freq, float phase) sampleProvider;

    invariant
    {
        assert(sampleRateHz > 0);
    }

    this(float sampleRateHz)
    {
        assert(sampleRateHz > 0);
        this.sampleRateHz = sampleRateHz;
    }

    void sound(T[] buffer, float freqHz = 0, float amplitude0to1 = 0.9, float phase = 0)
    {
        onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, frameTime, time) {
            //time = time / channels;
            auto sample = sampleProvider ? sampleProvider(frameTime, freqHz, phase) : sampleFunc(frameTime, freqHz, phase);
            sample *= amplitude0to1;
            sample *= adsr.adsr(time);
            return sample;
        });
    }

    void fadeInOut(T[] buffer)
    {
        //≥10 мс
        size_t samples = cast(size_t)(10.0 / 1000 * sampleRateHz);
        fadein(buffer, samples, channels);
        fadeout(buffer, samples, channels);
    }
}
