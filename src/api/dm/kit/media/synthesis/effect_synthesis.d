module api.dm.kit.media.synthesis.effect_synthesis;

import Math = api.math;

/**
 * Authors: initkfs
 */
struct ADSR
{
    double attack = 0.1;
    double decay = 0.2;
    double sustain = 0.7;
    double release = 0.2;

    double adsr(double time)
    {
        //sample * adsr(..)
        //(Attack + Decay + Release) <= duration

        const double releaseTime = 1 - release;

        //Attack
        if (time < attack)
        {
            return time / attack;
            //return Math.sin((Math.PI / 2.0) * (time / attack));
        }
        //Decay
        else if (time < (attack + decay))
        {
            //return 1.0 - (1.0 - sustain) * (attack / decay);
            return 1.0 - (1.0 - sustain) * Math.pow((time - attack) / decay, 0.5);
        }
        //Release
        else if (time > releaseTime)
        {
            return sustain * (1 - ((time - releaseTime) / release));
            //return sustain * ((time - (1 - release)) / release);
        }

        return sustain;
    }
}

double adsr(double time)
{
    //sample * adsr(..)
    double attack = 0.1;
    double decay = 0.2;
    double sustain = 0.7;
    double release = 0.2;

    //(Attack + Decay + Release) <= duration

    const double releaseTime = 1 - release;

    //Attack
    if (time < attack)
    {
        return time / attack;
        //return Math.sin((Math.PI / 2.0) * (time / attack));
    }
    //Decay
    else if (time < (attack + decay))
    {
        //return 1.0 - (1.0 - sustain) * (attack / decay);
        return 1.0 - (1.0 - sustain) * Math.pow((time - attack) / decay, 0.5);
    }
    //Release
    else if (time > releaseTime)
    {
        return sustain * (1 - ((time - releaseTime) / release));
        //return sustain * ((time - (1 - release)) / release);
    }

    return sustain;
}

double lpf(double sample, double prev, double cutoff)
{
    return prev + cutoff * (sample - prev); // cutoff ~0.1-0.3
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

void fadeout(T)(T[] buffer, size_t samples, size_t channels)
{
    assert(buffer.length > 0);
    assert(samples * channels < buffer.length);

    size_t start = buffer.length - samples * channels;

    for (auto i = start; i < buffer.length; i += channels)
    {
        double factor = 1.0 - (((cast(double) i) - start) / channels) / samples;

        for (size_t ch = 0; ch < channels; ch++)
        {
            auto buffIndex = i + ch;
            if (buffIndex >= buffer.length)
            {
                break;
            }
            buffer[buffIndex] = cast(T)(buffer[buffIndex] * factor);
        }
    }
}

void fadein(T)(T[] buffer, size_t samples, size_t channels = 2)
{
    for (auto i = 0; i < samples * channels; i += channels)
    {
        double factor = ((cast(double) i) / channels) / samples;

        for (auto ch = 0; ch < channels; ch++)
        {
            size_t buffIndex = i + ch;
            if (buffIndex >= buffer.length)
            {
                break;
            }
            buffer[buffIndex] = cast(T)(buffer[buffIndex] * factor);
        }
    }
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

double overtones(double time, double freq, double phase)
{
    double sample = 0.0;
    sample += Math.sin(Math.PI2 * freq * time + phase) * 0.7;
    sample += Math.sin(Math.PI2 * 2.0 * freq * time + 2 * phase) * 0.3;
    sample += Math.sin(Math.PI2 * 3.0 * freq * time + 3 * phase) * 0.1;
    sample += Math.sin(Math.PI2 * 4.0 * freq * time + 4 * phase) * 0.05;
    return sample;
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
