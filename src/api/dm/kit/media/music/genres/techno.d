module api.dm.kit.media.music.genres.techno;

import api.dm.kit.media.synthesis.signal_synthesis;

import Math = api.math;

void kick(T)(T[] buffer, double freqStart, double freqEndHz, double sampleRateHz, double frequency, double amplitude0to1 = 1.0, size_t channels = 2)
{
    import std.math: exp;

    // onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
    //     double t = (cast(double) i) / buffer.length;
    //     double freq = freqStart + (freqEndHz - freqStart) * (1.0 - t);
    //     double phase = Math.PI2 * freq * t;
    //     return Math.sin(phase) * exp(-4.0 * t);
    // });
}
