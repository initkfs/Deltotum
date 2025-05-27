module api.dm.addon.media.dsp.synthesis.signal_synthesis;

import api.dm.addon.media.dsp.signal_funcs;

import Math = api.math;

/**
 * Authors: initkfs
 */
double sine(double time, double freq, double phase)
{
    //phase == [0, 1)
    return Math.sin(Math.PI2 * freq * time + phase);
}

double sinovertones(double time, double freq, double phase)
{
    double sample = Math.sin(Math.PI2 * freq * time + phase) * 0.7;
    sample += Math.sin(Math.PI2 * 2.0 * freq * time + 2 * phase) * 0.3;
    sample += Math.sin(Math.PI2 * 3.0 * freq * time + 3 * phase) * 0.1;
    sample += Math.sin(Math.PI2 * 4.0 * freq * time + 4 * phase) * 0.05;
    return sample;
}

double square(double time, double freq, double phase)
{
    import std.math : fmod;

    return (Math.sin(Math.PI2 * freq * time + phase) >= 0) ? 1 : 0;
    //return (fmod(freq * time + phase, 1.0) < 0.5) ? 1.0 : -1.0;
}

double sawtooth(double time, double freq, double phase)
{
    import std.math : fmod;

    return fmod(time * freq + phase, 1.0);
}

double triangle(double time, double freq, double phase)
{
    //return 1.0 - 4.0 * Math.abs(fmod(freq * time + phase, 1.0) - 0.5);
    return (2.0 * Math.abs(2.0 * ((time * freq + phase) - Math.floor(time * freq + 0.5))) - 1.0);
}

struct FMdata
{
    double fc = 0;
    double fm = 0;
    double index = 0;
    double durationMs = 0;
    bool isFcMulFm;
}

double fmodulator(double time, double phase, double fc, double fm, double index)
{
    return Math.sin((Math.PI2 * fc * time + phase) + index * Math.sin(Math.PI2 * fm * time));
}

import api.math.random : Random;

double whiteNoise(Random rnd)
{
    return rnd.between!double(-1, 1);
}

// void chaoticLogistic(T)(T[] buffer, double r, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels = 2)
// {
//     double x = 0.5;
//     onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
//         x = r * x * (1.0 - x);
//         return (x - 0.5f) * 2.0;
//     });
// }

// void poissonNoise(T)(Random rnd, T[] buffer, double rate, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels = 2)
// {
//     double threshold = 1.0 - rate / sampleRateHz;

//     onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
//         return (rnd.between0to1 > threshold) ? 1 : 0;
//     });
// }

// void fractalNoise(T)(Random rnd, T[] buffer, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels = 2)
// {
//     import core.stdc.stdlib : malloc, free;

//     void* tempPtr = malloc(buffer.length * double.sizeof);
//     assert(tempPtr);

//     scope (exit)
//     {
//         free(tempPtr);
//     }

//     double[] temp = (cast(double*) tempPtr)[0 .. buffer.length];
//     assert(buffer.length == temp.length);

//     double value = 0;

//     foreach (ref t; temp)
//     {
//         value += (rnd.between0to1 - 0.5) * 0.1;
//         value *= 0.99;
//         t = value;
//     }

//     double max = 0.0;
//     foreach (ref t; temp)
//     {
//         const abst = Math.abs(t);
//         if (abst > max)
//         {
//             max = abst;
//         }
//     }

//     onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
//         return temp[i] / max;
//     });
// }

// void phaseDistortion(T)(T[] buffer, double freqHz, double distortion, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels = 2)
// {
//     import std.math : fmod;

//     double phaseDt = freqHz / sampleRateHz;
//     double phase = 0;

//     onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
//         phase = fmod(phase + phaseDt, 1.0);
//         double distortPhase = phase < distortion ? phase / distortion : (
//             1.0 - phase) / (1.0 - distortion);
//         return Math.sin(2.0f * Math.PI * distortPhase);
//     });
// }

// void polynomialWaveshaper(T)(T[] buffer, double freqHz, double a, double b, double c, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels = 2)
// {
//     double phaseDt = freqHz / sampleRateHz;
//     double phase = 0;

//     onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
//         phase = fmod(phase + phaseDt, 1.0);
//         dobule x = 2.0 * phase - 1.0;
//         double y = a * x + b * x * x * x + c * x * x * x * x * x;
//         return y;
//     });
// }

// void diracImpulses(T)(T[] buffer, size_t period, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels = 2)
// {
//     onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
//         return (i % period == 0) ? 1 : 0;
//     });
// }

// void am(T)(T[] buffer, double fc, double fm, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels = 2)
// {
//     double carrierDt = fc / sampleRateHz;
//     double modDt = fm / sampleRateHz;

//     double carrierPhase = 0;
//     double modPhase = 0;

//     import std.math : fmod;

//     onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {

//         carrierPhase = fmod(carrierPhase + carrierDt, 1.0);
//         modPhase = fmod(modPhase + modDt, 1.0);

//         double mod = 0.5 * (1.0 + Math.sin(Math.PI2 * modPhase));
//         double carrier = Math.sin(Math.PI2 * carrierPhase);

//         return mod * carrier;
//     });
// }
