module api.dm.kit.media.synthesis.chord_synthesis;

import api.dm.kit.media.synthesis.signal_synthesis;
import api.dm.kit.media.synthesis.effect_synthesis;

import Math = api.math;

/**
 * Authors: initkfs
 */

//(C4, E4, G4)
double[3] chord_frequencies = [261.63, 329.63, 392.00];

void chord(T)(T[] buffer, double sampleRateHz = 44100, double amplitude0to1 = 0.3, size_t channels = 2)
{
    onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
        
        double sample = 0.0;

        foreach (freq; chord_frequencies)
        {
            //sample += Math.sin(2.0f * Math.PI * chord_frequencies[n] * time) * adsr(time, durationSec) * amplitude0to1;
            sample += Math.sin(Math.PI2 * freq * time);
        }

        return sample;
    });
}

double piano(double time, double freq, double duration)
{
    double sample = Math.sin(2 * Math.PI * freq * time) * 0.5;
    sample += Math.sin(2 * Math.PI * 2 * freq * time) * 0.3;
    sample += Math.sin(2 * Math.PI * 3 * freq * time) * 0.2;

    sample *= adsr(time, duration);

    //sample = lowpassFilter(sample, 0.2);

    //if (time < 0.01) sample += (rand() % 2000 - 1000) / 32768.0f;

    return sample;
}
