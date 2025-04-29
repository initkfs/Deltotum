module api.dm.com.audio.com_audio_device;

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.audio.com_audio_clip : ComAudioClip;
import api.dm.com.audio.com_audio_chunk : ComAudioChunk;

alias ComAudioDeviceId = uint;

enum ComAudioFormat
{
    none,
    s16,
    s32,
    f32
}

struct ComAudioSpec
{
    ComAudioFormat format = ComAudioFormat.f32;
    int freqHz = 48000;
    size_t channels = 2;
}

/**
 * Authors: initkfs
 */
interface ComAudioDevice
{
nothrow:

    ComResult open(const ComAudioSpec* requestSpec = null);
    ComResult close();

    ComResult getSpec(out ComAudioSpec requestSpec);

    ComAudioDeviceId id();
    ComAudioSpec spec();
}
