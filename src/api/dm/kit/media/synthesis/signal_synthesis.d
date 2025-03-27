module api.dm.kit.media.synthesis.signal_synthesis;

import api.core.components.units.simple_unit : SimpleUnit;

/**
 * Authors: initkfs
 */
void sine(T)(T[] buffer, double sampleRate, double frequency, double amplitude0to1 = 1.0)
{
    foreach (i, ref v; buffer)
    {
        double time = i / sampleRate;
        double value = Math.sin(2.0 * Math.PI * frequency * time) * amplitude0to1;
        v = cast(T)(value * T.max);
    }
}

void square(T)(T[] buffer, double sampleRate, double frequency, double amplitude0to1 = 1.0)
{
    foreach (i, ref v; buffer)
    {
        double time = i / sampleRate;
        //>= 0) ? 127 : -128
        double value = (Math.sin(2.0 * Math.PI * frequency * time) >= 0) ? (T.max - 1) : -T.max;
        v = value * amplitude0to1;
    }
}

void sawtooth(T)(T[] buffer, double sampleRate, double frequency, double amplitude0to1 = 1.0)
{
    foreach (i, ref v; buffer)
    {
        double time = i / sampleRate;
        v = cast(T)(T.max * (Math.fmod(time * frequency, 1.0) - 0.5));
    }
}

void triangle(T)(T[] buffer, double sampleRate, double frequency, double amplitude0to1 = 1.0)
{
    foreach (i, ref v; buffer)
    {
        double time = i / sampleRate;
        v = cast(T)(T.max * (2.0 * Math.abs(
                2.0 * (time * frequency - Math.floor(time * frequency + 0.5))) - 1.0));
    }
}

import api.math.random : Random;

void whiteNoise(T)(Random rnd, T[] buffer, double sampleRate, double frequency, double amplitude0to1 = 1.0)
{
    foreach (ref v; buffer)
    {
        //TODO type form?
        v = cast(T)(rnd.between(-T.max, T.max) % T.max - (T.max / 2));
    }
}

void fm(T)(T[] buffer, double sampleRate, double fc, double fm, double index)
{
    foreach (i, ref v; buffer)
    {
        double time = i / sampleRate;
        double sample = Math.sin(2 * Math.PI * fc * time + index * Math.sin(2 * PI * fm * time));
        v = cast(T)(sample * T.max * 0.3);
    }
}
