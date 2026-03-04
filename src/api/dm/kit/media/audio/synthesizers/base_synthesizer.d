module api.dm.kit.media.audio.synthesizers.base_synthesizer;

import api.dm.kit.media.audio.chunks.audio_chunk;
import api.dm.kit.media.dsp.synthesis.effect_synthesis;
import api.dm.kit.media.dsp.synthesis.signal_synthesis;

import api.dm.kit.media.dsp.analog_signals;

import Math = api.math;

/**
 * Authors: initkfs
 */

class BaseSynthesizer
{
    float sampleRateHz = 0;
    size_t channels = 2;

    bool isFadeInOut = true;

    ADSR adsr;

    float function(float time, float freq, float phase) sampleFunc = &sinovertones;
    float delegate(float time, float freq, float phase) sampleProvider;

    this(float sampleRateHz)
    {
        if (sampleRateHz <= 0)
        {
            throw new Exception("Frequency must positive number");
        }
        this.sampleRateHz = sampleRateHz;
    }

    void MixSound(float[] buffer, float freqHz = 0, float amplitude0to1 = 0.9, float phase = 0)
    {
        onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, frameTime, time) {
            //time = time / channels;
            auto sample = sampleProvider ? sampleProvider(frameTime, freqHz, phase) : sampleFunc(frameTime, freqHz, phase);
            sample *= amplitude0to1;
            sample *= adsr.adsr(time);
            return sample;
        });
    }

    void fadeInOut(float[] buffer)
    {
        //≥10 мс
        size_t samples = cast(size_t)(10.0 / 1000 * sampleRateHz);
        fadein(buffer, samples, channels);
        fadeout(buffer, samples, channels);
    }
}
