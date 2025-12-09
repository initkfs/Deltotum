module api.dm.addon.dsp.synthesis.effect_synthesis;

import api.dm.addon.dsp.signal_funcs;

import Math = api.math;

/**
 * Authors: initkfs
 */
struct ADSR
{
    //sample * adsr(..)
    float attack = 0.2;
    float decay = 0.2;
    float sustain = 0.7;
    float release = 0.2;

    float adsr(float time)
    {
        //(Attack + Decay + Release) <= duration
        const float releaseTime = 1 - release;

        //Attack
        if (time < attack)
        {
            return time / attack;
            //return Math.sin((Math.PI / 2.0) * (time / attack));
        }

        //Release
        if (time > releaseTime)
        {
            if (time >= 1)
                return 0;
            const ampDt = (1 - ((time - releaseTime) / release));
            if (ampDt < 0.001)
                return 0;
            return sustain * ampDt;
            //return sustain * (1 - time / releaseTime);
            //return sustain * (1 - ((time - releaseTime) / release));
            //return sustain * ((time - (1 - release)) / release);
        }

        //Decay
        if (time < (attack + decay))
        {
            //return 1.0 - (1.0 - sustain) * (attack / decay);
            return 1.0 - (1.0 - sustain) * Math.pow((time - attack) / decay, 0.5);
        }

        return sustain;
    }
}

bool fadein(T)(T[] buffer, size_t samples, size_t channels = 2)
{
    if (samples * channels < buffer.length)
    {
        return false;
    }

    for (auto i = 0; i < samples * channels; i += channels)
    {
        float factor = ((cast(float) i) / channels) / samples;

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
    return true;
}

bool fadeout(T)(T[] buffer, size_t samples, size_t channels)
{
    assert(buffer.length > 0);
    if (samples * channels < buffer.length)
    {
        return false;
    }

    size_t start = buffer.length - samples * channels;

    for (auto i = start; i < buffer.length; i += channels)
    {
        float factor = 1.0 - (((cast(float) i) - start) / channels) / samples;

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

    return true;
}

float distortionHard(float sample, float threshold)
{
    return Math.max(Math.min(sample, threshold), -threshold);
}

float distortionSoft(float sample, float gain = 0.3) => Math.tanh(sample * gain);

float distortionCube(float sample, float drive)
{
    return sample - (1.0 / 3.0) * sample * sample * sample * drive;
}

float lowpass(float prevSample, float currentSample, float cutoff)
{
    return prevSample + cutoff * (currentSample - prevSample); // cutoff ~0.1-0.3
}

//Low-Frequency Oscillator
//tremolo: output = signal * lfoValue
//vibrato: freq = base_freq + lfo_value * depth)
float lfo(float freq, float time)
{
    return 0.5 * (1.0 + Math.sin(Math.PI2 * freq * time));
}

float tremolo(float sample, float sampleTime, float freq = 5)
{
    return sample * lfo(freq, sampleTime);
}

float vibrato(float sampleTime, float baseFreq, float depthFromRate = 0.01, float rateHz = 6.0)
{
    auto freq = baseFreq * (1.0 + depthFromRate * Math.sin(Math.PI2 * rateHz * sampleTime));
    return Math.sin(Math.PI2 * freq * sampleTime);
}

/** 
 * 
 * up, C → E → G
 * down, G → E → C
 * up-down, C → G → E → C → G...	
 * random, E → C → G → E...
 */
float arpeggio(float time, float sample)
{
    if (time < 1.0)
        sample += Math.sin(2 * Math.PI * 261.63 * time) * 0.3; // C4
    else if (time < 2.0)
        sample += Math.sin(2 * Math.PI * 329.63 * time) * 0.3; // E4
    else
        sample += Math.sin(2 * Math.PI * 392.00 * time) * 0.3; // G4

    return sample;
}
