module api.dm.kit.media.audio.chunks.audio_chunk;

import api.dm.com.audio.com_audio_chunk : ComAudioChunk;
import api.dm.com.audio.com_audio_device : ComAudioSpec;
import api.dm.kit.media.buffers.finite_signal_buffer : FiniteSignalBuffer;

/**
 * Authors: initkfs
 */
class AudioChunk(T)
{
    ComAudioChunk comChunk;
    FiniteSignalBuffer!T data;
    ComAudioSpec spec;

    enum allTicks = -1;

    this(ComAudioChunk chunk, ComAudioSpec spec)
    {
        assert(chunk);
        this.comChunk = chunk;

        this.spec = spec;
    }

    void loop(int ticks = allTicks)
    {
        play(-1, ticks);
    }

    void play(int loops = 0, int ticks = allTicks)
    {
        if (const err = comChunk.play(loops, ticks))
        {
            //TODO logger;
            throw new Exception(err.toString);
        }
    }

    void stop()
    {
        if (const err = comChunk.stop)
        {
            //TODO logger;
            throw new Exception(err.toString);
        }
    }

    int lastChannel()
    {
        assert(comChunk);
        return comChunk.lastChannel;
    }

    void onBuffer(scope void delegate(T[] buff, ComAudioSpec) onBuff)
    {
        onBuff(data.buffer, spec);
    }

    void dispose()
    {
        assert(comChunk);
        comChunk.dispose;

        data.dispose;
    }
}
