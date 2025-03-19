module api.dm.kit.media.dsp.window_funcs;

/**
 * Authors: initkfs
 */

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
        double winVal =  0.42 - 0.5 * Math.cos((2 * Math.PI * i) / (size - 1)) + 0.08 * Math.cos((4 * Math.PI * i) / (size - 1));
        data[i] = cast(T)(data[i] * winVal);
    }
}
