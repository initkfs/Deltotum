module api.dm.addon.dsp.signal_funcs;

/**
 * Authors: initkfs
 */
void onBuffer(T)(T[] buffer, double sampleRateHz, double amplitude0to1 = 1.0, size_t channels, scope double delegate(
        size_t, double, double) onIndexFrameTimeNormTime)
{
    assert(buffer.length > 0);

    const frameTimeDt = 1.0 / sampleRateHz;
    const normTimeDt = 1.0 / (buffer.length / channels);

    const bool isMultiChans = channels > 1;
    const bool isStereo = channels == 2;

    double frameTime = 0;
    double normTime = 0;
    for (size_t i = 0; i < buffer.length; i += channels)
    {
        double value = onIndexFrameTimeNormTime(i, frameTime, normTime);
        T buffValue = cast(T)(value * amplitude0to1 * T.max);
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

        frameTime += frameTimeDt;
        normTime += normTimeDt;
    }
}

void hann(T)(T[] data)
{
    import Math = std.math;

    auto size = data.length;
    if (size == 0)
    {
        return;
    }

    foreach (i, v; data)
    {
        double winVal = 0.5 * (1 - Math.cos((2 * Math.PI * i) / (size - 1)));
        data[i] = cast(T)(data[i] * winVal);
    }
}

void hamming(T)(T[] data)
{
    import Math = std.math;

    auto size = data.length;

    if (size == 0)
    {
        return;
    }

    foreach (i, v; data)
    {
        double winVal = 0.54 - 0.46 * Math.cos((2 * Math.PI * i) / (size - 1));
        data[i] = cast(T)(data[i] * winVal);
    }
}

void blackman(T)(T[] data)
{
    import Math = std.math;

    auto size = data.length;

    if (size == 0)
    {
        return;
    }

    foreach (i, v; data)
    {
        double winVal = 0.42 - 0.5 * Math.cos(
            (2 * Math.PI * i) / (size - 1)) + 0.08 * Math.cos((4 * Math.PI * i) / (size - 1));
        data[i] = cast(T)(data[i] * winVal);
    }
}
