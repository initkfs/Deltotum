module api.dm.com.audio.com_audio_device;

import api.dm.com.com_result : ComResult;
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
    int freqHz = 44100;
    size_t channels = 2;

    size_t bytesPerOnSample() const  pure nothrow
    {
        final switch (format) with (ComAudioFormat)
        {
            case s16:
                return 2;
            case s32, f32:
                return 4;
            case none:
                return 0;
        }
    }

    size_t bytesPerSample() const  pure nothrow => bytesPerOnSample * channels;
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
