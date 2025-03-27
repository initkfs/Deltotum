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
    ComAudioFormat format = ComAudioFormat.s16;
    int channels = 2;
    int freq = 44100;
}

/**
 * Authors: initkfs
 */
interface ComAudioDevice
{
nothrow:

    ComResult open(const ComAudioSpec* requestSpec = null);
    ComResult getSpec(out ComAudioSpec requestSpec);

    ComAudioDeviceId id();
    ComAudioSpec spec();

    void close();

}
