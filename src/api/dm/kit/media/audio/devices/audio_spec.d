module api.dm.kit.media.audio.devices.audio_spec;

/**
 * Authors: initkfs
 */

enum AudioFormat
{
    none,
    s16,
    s32,
    f32
}

struct AudioSpec
{
    AudioFormat format = AudioFormat.f32;
    int freqHz = 44100;
    size_t channels = 2;

    size_t bytesPerOnSample() const pure nothrow
    {
        final switch (format) with (AudioFormat)
        {
            case s16:
                return 2;
            case s32, f32:
                return 4;
            case none:
                return 0;
        }
    }

    size_t bytesPerSample() const pure nothrow => bytesPerOnSample * channels;
}
