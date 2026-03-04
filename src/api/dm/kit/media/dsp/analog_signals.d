module api.dm.kit.media.dsp.analog_signals;

/**
 * Authors: initkfs
 */

struct AnalogSignal
{
    float freqHz = 0;
    float magn = 0;
}

void onBuffer(float[] buffer, float sampleRateHz, float amplitude0to1 = 1.0, size_t channels, scope float delegate(
        size_t, float, float) onIndexFrameTimeNormTime)
{
    assert(buffer.length > 0);

    const frameTimeDt = 1.0 / sampleRateHz;
    const normTimeDt = 1.0 / (buffer.length / channels);

    const bool isMultiChans = channels > 1;
    const bool isStereo = channels == 2;

    float frameTime = 0;
    float normTime = 0;
    for (size_t i = 0; i < buffer.length; i += channels)
    {
        float value = onIndexFrameTimeNormTime(i, frameTime, normTime);
        value *= amplitude0to1;

        buffer[i] = value;

        if (isStereo)
        {
            auto nextIndex = i + 1;
            if (nextIndex < buffer.length)
            {
                buffer[nextIndex] = value;
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
                buffer[nextIndex] = value;
            }
        }

        frameTime += frameTimeDt;
        normTime += normTimeDt;
    }
}

void hann(float[] data)
{
    import Math = std.math;

    auto size = data.length;
    if (size == 0)
    {
        return;
    }

    foreach (i, ref v; data)
    {
        float winVal = 0.5 * (1 - Math.cos((2 * Math.PI * i) / (size - 1)));
        v = v * winVal;
    }
}

void hamming(float[] data)
{
    import Math = std.math;

    auto size = data.length;

    if (size == 0)
    {
        return;
    }

    foreach (i, ref v; data)
    {
        float winVal = 0.54 - 0.46 * Math.cos((2 * Math.PI * i) / (size - 1));
        v = v * winVal;
    }
}

void blackman(float[] data)
{
    import Math = std.math;

    auto size = data.length;

    if (size == 0)
    {
        return;
    }

    foreach (i, ref v; data)
    {
        float winVal = 0.42 - 0.5 * Math.cos(
            (2 * Math.PI * i) / (size - 1)) + 0.08 * Math.cos((4 * Math.PI * i) / (size - 1));
        v = v * winVal;
    }
}
