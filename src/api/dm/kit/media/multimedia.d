module api.dm.kit.media.multimedia;

import api.core.components.units.simple_unit : SimpleUnit;
import api.dm.kit.media.audio.devices.audio_spec: AudioSpec, AudioFormat;
import api.dm.kit.media.audio.engines.audio_engine: AudioEngine;

/**
 * Authors: initkfs
 */
class MultiMedia : SimpleUnit
{
    AudioSpec audioOutSpec;
    AudioEngine audio;

    this(AudioSpec audioOutSpec, AudioEngine audioPlayer)
    {
        this.audioOutSpec = audioOutSpec;
        assert(audioPlayer);
        this.audio = audioPlayer;
    }

    import api.dm.kit.media.audio.chunks.audio_chunk : AudioChunk;

    AudioChunk!T* newHeapBuffer(T)(float durationMsec) => newHeapBuffer!T(durationMsec,audioOutSpec.channels);

    AudioChunk!T* newHeapBuffer(T)(float durationMsec, size_t channels)
    {
        auto freqHz = audioOut.spec.freqHz;
        
        auto buff = new AudioChunk!T(freqHz, durationMsec, channels);
        return buff;
    }
}
