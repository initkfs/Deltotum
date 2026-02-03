module api.dm.kit.media.multimedia;

import api.core.components.units.simple_unit : SimpleUnit;
import api.dm.com.audio.com_audio_device : ComAudioDevice, ComAudioSpec;
import api.dm.com.audio.com_audio_chunk : ComAudioChunk;
import api.dm.com.audio.com_audio_clip : ComAudioClip;

/**
 * Authors: initkfs
 */
class MultiMedia : SimpleUnit
{
    ComAudioDevice audioOut;

    this(ComAudioDevice audioOut)
    {
        assert(audioOut);
        this.audioOut = audioOut;
    }

    ComAudioSpec audioOutSpec()
    {
        ComAudioSpec spec;
        if (const err = audioOut.getSpec(spec))
        {
            //TODO logging;
            throw new Exception(err.toString);
        }
        return spec;
    }

    import api.dm.kit.media.buffers.finite_signal_buffer : FiniteSignalBuffer;

    FiniteSignalBuffer!T* newHeapChunk(T)(float durationMsec) => newHeapChunk!T(durationMsec, cast(size_t) audioOut
            .spec.channels);

    FiniteSignalBuffer!T* newHeapChunk(T)(float durationMsec, size_t channels)
    {
        auto freqHz = audioOut.spec.freqHz;
        
        auto buff = new FiniteSignalBuffer!T(freqHz, durationMsec, channels);
        return buff;
    }
}
