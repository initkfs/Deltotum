module api.dm.kit.media.audio.chunks.audio_chunk;

import Math = api.math;

import core.stdc.stdlib : malloc, free;

/**
 * Authors: initkfs
 */
struct AudioChunk
{
    float freqHz = 0;
    float durationMs = 0;
    size_t channels = 1;

    private
    {
        float[] _buffer;
        bool _freed;
    }

    this(float freqHz, float durationMs, size_t channels = 2, bool isClearBuffer = true)
    {
        import std.math.traits : isFinite;

        assert(freqHz > 0);
        if (freqHz <= 0 || !isFinite(freqHz))
        {
            import std.conv : text;

            throw new Exception("Frequency must be positive number: " ~ text(freqHz));
        }

        this.freqHz = freqHz;

        if (durationMs <= 0 || !isFinite(durationMs))
        {
            import std.conv : text;

            throw new Exception("Duration must be positive number: " ~ text(durationMs));
        }

        this.durationMs = durationMs;

        if (channels == 0)
        {
            throw new Exception("Channels must not be 0");
        }

        this.channels = channels;

        size_t buffLen = (cast(size_t)(Math.round(durationMs / 1000 * freqHz)) * channels);

        auto buffPtr = malloc(buffLen * float.sizeof);
        if (!buffPtr)
        {
            throw new Exception("Buffer allocation error");
        }

        _buffer = (cast(float*) buffPtr)[0 .. buffLen];

        if (isClearBuffer)
        {
            _buffer[] = 0;
        }
    }

    ~this()
    {
        dispose;
    }

    bool dispose()
    {
        if (_freed || _buffer.length == 0)
        {
            return true;
        }

        free(_buffer.ptr);
        _buffer = null;
        _freed = true;
        return true;
    }

    inout(float[]) buffer() inout => _buffer;

    bool isFreed() const nothrow @safe => _freed;
}
