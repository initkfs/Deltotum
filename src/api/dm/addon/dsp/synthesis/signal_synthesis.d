module api.dm.addon.dsp.synthesis.signal_synthesis;

import api.dm.addon.dsp.signal_funcs;

import Math = api.math;

/**
 * Authors: initkfs
 */
float sine(float time, float freq, float phase)
{
    //phase == [0, 1)
    return Math.sin(Math.PI2 * freq * time + phase);
}

float sinovertones(float time, float freq, float phase)
{
    float sample = Math.sin(Math.PI2 * freq * time + phase) * 0.7;
    sample += Math.sin(Math.PI2 * 2.0 * freq * time + 2 * phase) * 0.3;
    sample += Math.sin(Math.PI2 * 3.0 * freq * time + 3 * phase) * 0.1;
    sample += Math.sin(Math.PI2 * 4.0 * freq * time + 4 * phase) * 0.05;
    return sample;
}

float square(float time, float freq, float phase)
{
    import std.math : fmod;

    return (Math.sin(Math.PI2 * freq * time + phase) >= 0) ? 1 : 0;
    //return (fmod(freq * time + phase, 1.0) < 0.5) ? 1.0 : -1.0;
}

float sawtooth(float time, float freq, float phase)
{
    import std.math : fmod;

    return fmod(time * freq + phase, 1.0);
}

float triangle(float time, float freq, float phase)
{
    //return 1.0 - 4.0 * Math.abs(fmod(freq * time + phase, 1.0) - 0.5);
    return (2.0 * Math.abs(2.0 * ((time * freq + phase) - Math.floor(time * freq + 0.5))) - 1.0);
}

struct FMdata
{
    float fc = 0;
    float fm = 0;
    float index = 0;
    float durationMs = 0;
    bool isFcMulFm;
}

float fmodulator(float time, float phase, float fc, float fm, float index)
{
    return Math.sin((Math.PI2 * fc * time + phase) + index * Math.sin(Math.PI2 * fm * time));
}

import api.math.random : Random;

float whiteNoise(Random rnd)
{
    return rnd.between!float(-1, 1);
}

// void chaoticLogistic(T)(T[] buffer, float r, float sampleRateHz, float amplitude0to1 = 1.0, size_t channels = 2)
// {
//     float x = 0.5;
//     onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
//         x = r * x * (1.0 - x);
//         return (x - 0.5f) * 2.0;
//     });
// }

// void poissonNoise(T)(Random rnd, T[] buffer, float rate, float sampleRateHz, float amplitude0to1 = 1.0, size_t channels = 2)
// {
//     float threshold = 1.0 - rate / sampleRateHz;

//     onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
//         return (rnd.between0to1 > threshold) ? 1 : 0;
//     });
// }

// void fractalNoise(T)(Random rnd, T[] buffer, float sampleRateHz, float amplitude0to1 = 1.0, size_t channels = 2)
// {
//     import core.stdc.stdlib : malloc, free;

//     void* tempPtr = malloc(buffer.length * float.sizeof);
//     assert(tempPtr);

//     scope (exit)
//     {
//         free(tempPtr);
//     }

//     float[] temp = (cast(float*) tempPtr)[0 .. buffer.length];
//     assert(buffer.length == temp.length);

//     float value = 0;

//     foreach (ref t; temp)
//     {
//         value += (rnd.between0to1 - 0.5) * 0.1;
//         value *= 0.99;
//         t = value;
//     }

//     float max = 0.0;
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

// void phaseDistortion(T)(T[] buffer, float freqHz, float distortion, float sampleRateHz, float amplitude0to1 = 1.0, size_t channels = 2)
// {
//     import std.math : fmod;

//     float phaseDt = freqHz / sampleRateHz;
//     float phase = 0;

//     onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
//         phase = fmod(phase + phaseDt, 1.0);
//         float distortPhase = phase < distortion ? phase / distortion : (
//             1.0 - phase) / (1.0 - distortion);
//         return Math.sin(2.0f * Math.PI * distortPhase);
//     });
// }

// void polynomialWaveshaper(T)(T[] buffer, float freqHz, float a, float b, float c, float sampleRateHz, float amplitude0to1 = 1.0, size_t channels = 2)
// {
//     float phaseDt = freqHz / sampleRateHz;
//     float phase = 0;

//     onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
//         phase = fmod(phase + phaseDt, 1.0);
//         dobule x = 2.0 * phase - 1.0;
//         float y = a * x + b * x * x * x + c * x * x * x * x * x;
//         return y;
//     });
// }

// void diracImpulses(T)(T[] buffer, size_t period, float sampleRateHz, float amplitude0to1 = 1.0, size_t channels = 2)
// {
//     onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {
//         return (i % period == 0) ? 1 : 0;
//     });
// }

// void am(T)(T[] buffer, float fc, float fm, float sampleRateHz, float amplitude0to1 = 1.0, size_t channels = 2)
// {
//     float carrierDt = fc / sampleRateHz;
//     float modDt = fm / sampleRateHz;

//     float carrierPhase = 0;
//     float modPhase = 0;

//     import std.math : fmod;

//     onBuffer(buffer, sampleRateHz, amplitude0to1, channels, (i, time) {

//         carrierPhase = fmod(carrierPhase + carrierDt, 1.0);
//         modPhase = fmod(modPhase + modDt, 1.0);

//         float mod = 0.5 * (1.0 + Math.sin(Math.PI2 * modPhase));
//         float carrier = Math.sin(Math.PI2 * carrierPhase);

//         return mod * carrier;
//     });
// }
