module api.dm.kit.media.synthesis.signal_synthesis;

import Math = api.math;

/**
 * Authors: initkfs
 */

void onBuffer(T)(T[] buffer, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels, scope double delegate(
        size_t, double) onIndexTimeStep)
{
    assert(buffer.length > 0);

    const timeDt = 1.0 / sampleRateHz * channels;
    const bool isMultiChans = channels > 1;
    const bool isStereo = channels == 2;

    double time = 0;
    for (size_t i = 0; i < buffer.length; i += channels)
    {
        time += timeDt;
        //double time =  ((cast(double)i) / channels) / sampleRateHz;
        double value = onIndexTimeStep(i, time) * amplitude0to1;
        T buffValue = cast(T)(value * T.max);
        buffer[i] = buffValue;

        if (isStereo)
        {
            auto nextIndex = i + 1;
            if (nextIndex < buffer.length)
            {
                buffer[nextIndex] = buffValue;
            }
        }
        else if (isMultiChans)
        {
            foreach (ch; 1 .. channels)
            {
                auto nextIndex = i + ch;
                if (nextIndex >= buffer.length)
                {
                    break;
                }
                buffer[nextIndex] = buffValue;
            }
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

void chaoticLogistic(T)(T[] buffer, double r, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels = 2)
{
    double x = 0.5;
    onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
        x = r * x * (1.0 - x);
        return (x - 0.5f) * 2.0;
    });
}

void poissonNoise(T)(Random rnd, T[] buffer, double rate, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels = 2)
{
    double threshold = 1.0 - rate / sampleRateHz;

    onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
        return (rnd.between0to1 > threshold) ? 1 : 0;
    });
}

void fractalNoise(T)(Random rnd, T[] buffer, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels = 2)
{
    import core.stdc.stdlib : malloc, free;

    void* tempPtr = malloc(buffer.length * double.sizeof);
    assert(tempPtr);

    scope (exit)
    {
        free(tempPtr);
    }

    double[] temp = (cast(double*) tempPtr)[0 .. buffer.length];
    assert(buffer.length == temp.length);

    double value = 0;

    foreach (ref t; temp)
    {
        value += (rnd.between0to1 - 0.5) * 0.1;
        value *= 0.99;
        t = value;
    }

    double max = 0.0;
    foreach (ref t; temp)
    {
        const abst = Math.abs(t);
        if (abst > max)
        {
            max = abst;
        }
    }

    onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
        return temp[i] / max;
    });
}

void phaseDistortion(T)(T[] buffer, double freqHz, double distortion, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels = 2)
{
    import std.math : fmod;

    double phaseDt = freqHz / sampleRateHz;
    double phase = 0;

    onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
        phase = fmod(phase + phaseDt, 1.0);
        double distortPhase = phase < distortion ? phase / distortion : (
            1.0 - phase) / (1.0 - distortion);
        return Math.sin(2.0f * Math.PI * distortPhase);
    });
}

void polynomialWaveshaper(T)(T[] buffer, double freqHz, double a, double b, double c, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels = 2)
{
    double phaseDt = freqHz / sampleRateHz;
    double phase = 0;

    onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
        phase = fmod(phase + phaseDt, 1.0);
        dobule x = 2.0 * phase - 1.0;
        double y = a * x + b * x * x * x + c * x * x * x * x * x;
        return y;
    });
}

void diracImpulses(T)(T[] buffer, size_t period, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels = 2)
{
    onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
        return (i % period == 0) ? 1 : 0;
    });
}

void fm(T)(T[] buffer, double fc, double fm, double index, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels = 2)
{
    onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
        return Math.sin(2 * Math.PI * fc * time + index * Math.sin(2 * PI * fm * time));
    });
}

void am(T)(T[] buffer, double fc, double fm, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels = 2)
{
    double carrierDt = fc / sampleRateHz;
    double modDt = fm / sampleRateHz;

    double carrierPhase = 0;
    double modPhase = 0;

    import std.math : fmod;

    onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {

        carrierPhase = fmod(carrierPhase + carrierDt, 1.0);
        modPhase = fmod(modPhase + modDt, 1.0);

        double mod = 0.5 * (1.0 + Math.sin(Math.PI2 * modPhase));
        double carrier = Math.sin(Math.PI2 * carrierPhase);

        return mod * carrier;
    });
}
