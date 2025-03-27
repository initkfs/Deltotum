module api.dm.kit.media.synthesis.signal_synthesis;

import Math = api.math;

/**
 * Authors: initkfs
 */

protected void onBuffer(T)(T[] buffer, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels, scope double delegate(
        size_t, double) onIndexTimeStep)
{
    for (size_t i = 0; i < buffer.length; i++)
    {
        double time = i / sampleRateHz;
        double value = onIndexTimeStep(i, time) * amplitude0to1;
        T buffValue = cast(T)(value * T.max);
        buffer[i] = buffValue;
        if (channels > 1 && (++i) < buffer.length)
        {
            //TODO value * leftPan, right pan
            buffer[i] = buffValue;
        }
    }
}

void sine(T)(T[] buffer, double sampleRateHz, double frequency, double amplitude0to1 = 1.0, size_t channels = 2)
{
    onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
        return Math.sin(Math.PI2 * frequency * time);
    });
}

void square(T)(T[] buffer, double sampleRateHz, double frequency, double amplitude0to1 = 1.0, size_t channels = 2)
{
    onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
        return (Math.sin(Math.PI2 * frequency * time) >= 0) ? 1 : 0;
    });
}

void sawtooth(T)(T[] buffer, double sampleRateHz, double frequency, double amplitude0to1 = 1.0, size_t channels = 2)
{
    import std.math : fmod;

    onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
        return fmod(time * frequency, 1.0);
    });
}

void triangle(T)(T[] buffer, double sampleRateHz, double frequency, double amplitude0to1 = 1.0, size_t channels = 2)
{
    onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
        return (2.0 * Math.abs(2.0 * (time * frequency - Math.floor(time * frequency + 0.5))) - 1.0);
    });
}

import api.math.random : Random;

void whiteNoise(T)(Random rnd, T[] buffer, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels = 2)
{
    onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
        return rnd.between!double(-1, 1);
    });
}

void fm(T)(T[] buffer, double fc, double fm, double index, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels = 2)
{
    onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
        return Math.sin(2 * Math.PI * fc * time + index * Math.sin(2 * PI * fm * time));
    });
}
