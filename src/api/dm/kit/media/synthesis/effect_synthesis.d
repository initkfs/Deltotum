module api.dm.kit.media.synthesis.effect_synthesis;

import Math = api.math;

/**
 * Authors: initkfs
 */

double adsr(double time, double duration)
{
    double attack = 0.1, decay = 0.1, sustain = 0.7, release = 0.2;

    if (time < attack)
    {
        return time / attack;
    }
    else if (time < attack + decay)
    {
        return 1.0 - (1.0 - sustain) * ((time - attack) / decay);
    }
    else if (time < duration - release)
    {
        return sustain;
    }

    return sustain * (1.0 - (time - (duration - release)) / release);
}

double arpeggio(double time, double sample)
{
    if (time < 1.0f)
        sample += Math.sin(2 * Math.PI * 261.63f * time) * 0.3f; // C4
    else if (time < 2.0f)
        sample += Math.sin(2 * Math.PI * 329.63f * time) * 0.3f; // E4
    else
        sample += Math.sin(2 * Math.PI * 392.00f * time) * 0.3f; // G4
    
    return sample;
}

double tremolo(T)(T[] buffer, double sampleRate, double depth0to1 = 0.5, double rateHz = 5)
{
    foreach (i, ref v; buffer)
    {
        double time = cast(double) i / sampleRate;
        double modulation = 1.0f - depth0to1 * Math.sin(2.0 * Math.PI * rateHz * time);
        v *= modulation;
    }
}

double vibrato(T)(T[] buffer, double sampleRate, double baseFreq, double depthFromRate = 0.01, double rateHz = 6.0)
{
    foreach (i, ref v; buffer)
    {
        double time = cast(double) i / sampleRate;
        auto freq = baseFreq * (1.0 + depthFromRate * Math.sin(2.0 * Math.PI * rateHz * time));
        v = Math.sin(2.0 * Math.PI * freq * time) * T.max * 0.3f;
    }
}

double distortion(T)(T[] buffer, double threshold)
{
    foreach (i, ref v; buffer)
    {
        double sample = cast(double) i / T.max;
        sample = Math.max(Math.min(sample, threshold), -threshold);
        v = cast(T)(sample * T.max);
    }
}

double lowpassFilter(double prevSample, double currentSample, double alpha)
{
    return prevSample + alpha * (currentSample - prevSample);
}

void lowpass(T)(T[] buffer, double sampleRate, double cutoffFreq)
{
    double alpha = 1.0 - Math.exp(-2.0 * Math.PI * cutoffFreq / sampleRate);
    double prev = 0.0;
    foreach (i, ref v; buffer)
    {
        double sample = v / (cast(double) T.max);
        sample = lowpassFilter(prev, sample, alpha);
        v = cast(T)(sample * T.max);
        prev = sample;
    }
}

void overtones(T)(T[] buffer, double sampleRate, double baseFreq)
{
    foreach (i, ref v; buffer)
    {
        double time = cast(double) i / sampleRate;
        double sample = 0.0;
        // + 2 overtones
        sample += Math.sin(2.0 * Math.PI * baseFreq * time) * 0.5;
        sample += Math.sin(2.0 * Math.PI * 2.0 * baseFreq * time) * 0.3;
        sample += Math.sin(2.0 * Math.PI * 3.0 * baseFreq * time) * 0.2;
        v = cast(T)(sample * T.max);
    }
}

void echo(T)(T[] buffer, double sampleRate, double delaySec, double decay)
{
    auto delaySamples = cast(size_t)(delaySec * sampleRate);
    for (size_t i = delaySamples; i < length; i++)
    {
        buffer[i] += cast(T)(buffer[i - delaySamples] * decay);
    }
}

void reverb(T)(T[] buffer, double sampleRate)
{
    double[] delaysSec = [0.03, 0.05, 0.07];
    double[] decaysCoeff = [0.5, 0.3, 0.2];

    foreach (i; 0 .. 3)
    {
        echo(buffer, sampleRate, delaysSec[i], decaysCoeff[i]);
    }
}

void attackNoise(T)(Random rnd, T[] buffer, size_t attackSamples)
{
    foreach (i; 0 .. attack_samples)
    {
        float noise = (rnd.between(0, short.max) % 2000 - 1000) * (
            1.0 - cast(double) i / attackSamples);
        buffer[i] += cast(T) noise;
    }
}