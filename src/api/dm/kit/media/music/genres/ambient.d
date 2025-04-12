module api.dm.kit.media.music.genres.ambient;

import api.dm.kit.media.synthesis.signal_synthesis;

import Math = api.math;

//TODO House, Glitch

void drone(T)(T[] buffer, double freq, double sampleRateHz, double frequency, double amplitude0to1 = 1.0, size_t channels = 2)
{
    // onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
    //     // LFO 0.1Hz
    //     double lfo = Math.sin(Math.PI2 * 0.1 * time) * 5.0;
    //     double sample = Math.sin(Math.PI2 * (freq + lfo) * time) * 0.3;
    //     sample += Math.sin(Math.PI2 * (freq * 1.5 + lfo) * time) * 0.2;
    //     return sample;
    // });
}
