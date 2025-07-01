module api.dm.kit.media.buffers.finite_signal_buffer;

import Math = api.math;

import core.stdc.stdlib : malloc, free;

/**
 * Authors: initkfs
 */
struct FiniteSignalBuffer(T)
{
    double freqHz = 0;
    double durationMs = 0;
    size_t channels = 1;

    bool isFreed;

    private
    {
        T[] _buffer;
    }

    this(double freqHz, double durationMs, size_t channels = 2) nothrow
    {
        import std.math.traits : isFinite;

        assert(freqHz > 0);
        assert(isFinite(freqHz));

        this.freqHz = freqHz;

        assert(durationMs > 0);
        assert(isFinite(durationMs));

        this.durationMs = durationMs;

        assert(channels > 0);
        this.channels = channels;

        size_t buffLen = (cast(size_t)(Math.round(durationMs / 1000 * freqHz)) * channels);
        assert(buffLen > 0);

        auto buffPtr = malloc(buffLen * T.sizeof);
        assert(buffPtr);

        _buffer = (cast(T*) buffPtr)[0 .. buffLen];

        // static if (__traits(isFloating, T))
        // {
        //     _buffer[] = 0;
        // }
        // else
        // {
        //     _buffer[] = T.init;
        // }
    }

    void dispose()
    {
        assert(!isFreed);
        assert(_buffer.length > 0);
        free(_buffer.ptr);
        isFreed = true;
    }

    inout(T[]) buffer() inout => _buffer;

}
