module api.dm.kit.media.dsp.window_funcs;

/**
 * Authors: initkfs
 */

void hann(T)(T[] data)
{
    import Math = std.math;

    auto size = data.length;
    if(size == 0){
        return;
    }

    foreach (i, v; data)
    {
        double window_value = 0.5 * (1 - Math.cos(2 * Math.PI * i / (size - 1)));
        data[i] = cast(T)(data[i] * window_value);
    }
}
