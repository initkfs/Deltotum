module api.dm.kit.media.multimedia;

import api.core.components.units.simple_unit : SimpleUnit;
import api.dm.com.audio.com_audio_device : ComAudioDevice, ComAudioSpec;
import api.dm.com.audio.com_audio_chunk : ComAudioChunk;
import api.dm.com.audio.com_audio_clip: ComAudioClip;
import api.dm.kit.media.audio.chunks.audio_chunk : AudioChunk;
import api.dm.kit.media.audio.mixers.audio_mixer : AudioMixer;

/**
 * Authors: initkfs
 */
class MultiMedia : SimpleUnit
{
    ComAudioDevice audioOut;

    AudioMixer mixer;

    ComAudioChunk delegate(ubyte[]) chunkFromBufferProvider;

    this(AudioMixer mixer, ComAudioDevice audioOut)
    {
        assert(mixer);

        this.mixer = mixer;

        assert(audioOut);
        this.audioOut = audioOut;
    }
    ComAudioSpec audioOutSpec(){
        ComAudioSpec spec;
        if(const err = audioOut.getSpec(spec)){
            //TODO logging;
            throw new Exception(err.toString);
        }
        return spec;
    }

    AudioChunk!T newHeapChunk(T)(double durationMsec) => newHeapChunk!T(durationMsec, cast(size_t) audioOut.spec.channels);

    AudioChunk!T newHeapChunk(T)(double durationMsec, size_t channels)
    {
        auto freqHz = audioOut.spec.freqHz;
        import api.dm.kit.media.dsp.buffers.finite_signal_buffer : FiniteSignalBuffer;
        

        auto buff = FiniteSignalBuffer!T(freqHz, durationMsec, channels);

        assert(chunkFromBufferProvider);
        auto comChunk = chunkFromBufferProvider(cast(ubyte[]) buff.buffer);
        auto chunk = new AudioChunk!T(comChunk, audioOut.spec);
        chunk.data = buff;
        return chunk;
    }

    ComAudioClip newClip(string path){
        assert(mixer);
        auto clip = mixer.newClip(path);
        return clip;
    }
}
