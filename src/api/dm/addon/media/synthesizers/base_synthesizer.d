module api.dm.addon.media.synthesizers.base_synthesizer;

import api.dm.addon.media.dsp.buffers.finite_signal_buffer;
import api.dm.addon.media.dsp.synthesis.effect_synthesis;
import api.dm.addon.media.dsp.synthesis.signal_synthesis;

import api.dm.addon.media.dsp.signal_funcs;

import Math = api.math;

/**
 * Authors: initkfs
 */

class BaseSynthesizer(T)
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
