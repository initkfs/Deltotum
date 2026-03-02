module api.dm.kit.media.audio.devices.audio_stream;

import api.core.utils.queues.ring_buffer_lf : RingBufferLF;
import api.dm.kit.media.audio.devices.audio_spec : AudioFormat, AudioSpec;

import api.dm.lib.portaudio.native;
import Math = api.math;
import core.stdc.config : c_long, c_ulong;

import core.atomic : atomicLoad, atomicStore;

/**
 * Authors: initkfs
 */

//samples = ms × sample_rate / 1000
// bytes = samples × channels × bytes_per_sample

enum Latency
{
    lowLatency,
    interactive,
    standard,
    highStability,
    offline
}

enum
{
    FRAMES_PER_BUFFER = 512,
    BUFFER_MS = 100, // 100 ms
    BUFFER_SAMPLES = 4096, //
    CHANNELS = 2,
    TOTAL_BYTES = BUFFER_SAMPLES * CHANNELS * float.sizeof
}

enum AudioStreamState
{
    none,
    open,
    stop,
    close
}

class AudioStream(size_t Size = TOTAL_BYTES)
{
    AudioSpec spec;
    //TODO shared
    __gshared RingBufferLF!(float, Size, false, true) buffer;

    protected
    {
        PaStream* _stream;

        shared AudioStreamState _state;
    }

    void create()
    {
        buffer.initialize;
    }

    string lastError(PaError err)
    {
        import std.string : fromStringz;

        return Pa_GetErrorText(err).fromStringz.idup;
    }

    size_t size() => buffer.size;

    PaSampleFormat toSampleFormat(AudioFormat format)
    {
        final switch (format) with (AudioFormat)
        {
            case s16:
                return paInt16;
            case s32:
                return paInt32;
            case f32:
                return paFloat32;
            case none:
                return paFloat32;
        }
    }

    bool isOpen()
    {
        if (atomicLoad(_state) == AudioStreamState.open)
        {
            return true;
        }
        return false;
    }

    void open()
    {
        if (isOpen)
        {
            return;
        }

        if (_stream)
        {
            close;
        }

        PaStreamParameters outputParameters = {
            device: Pa_GetDefaultOutputDevice(),
            channelCount: cast(int) spec.channels,
            sampleFormat: toSampleFormat(spec.format),
            suggestedLatency: Pa_GetDeviceInfo(
                Pa_GetDefaultOutputDevice()
            ).defaultHighOutputLatency,
            hostApiSpecificStreamInfo: null
        };

        auto err = Pa_OpenStream(
            &_stream,
            null, // no output
            &outputParameters,
            spec.freqHz,
            FRAMES_PER_BUFFER,
            paClipOff,
            &audioCallback,
            cast(void*) this
        );

        if (err != PaErrorCode.paNoError)
        {
            throw new Exception("Failed to open audio stream: ", lastError(err));
        }

        err = Pa_StartStream(_stream);
        if (err != PaErrorCode.paNoError)
        {
            throw new Exception("Failed to start audio stream: ", lastError(err));
        }

        atomicStore(_state, AudioStreamState.open);
    }

    void stop()
    {
        if (!isOpen)
        {
            return;
        }

        //TODO must be shared?
        if (_stream)
        {
            Pa_StopStream(_stream);
        }

        atomicStore(_state, AudioStreamState.stop);
    }

    void close()
    {
        //TODO must be shared
        if (_stream)
        {
            Pa_CloseStream(_stream);
            _stream = null;
        }
        atomicStore(_state, AudioStreamState.close);
    }

    size_t writeAudio(float[] audioData)
    {
        return buffer.write(audioData);
    }

    static __gshared float[] readBuffer = new float[512 * 2];

    static extern (C) int audioCallback(
        const(void*) inputBuffer,
        void* outputBuffer,
        c_ulong framesPerBuffer,
        const(PaStreamCallbackTimeInfo*) timeInfo,
        PaStreamCallbackFlags statusFlags,
        void* userData)
    {
        try
        {
            AudioStream* player = cast(AudioStream*) userData;

            if (!player)
            {
                import std.stdio : stderr;

                stderr.writeln("Audio stream is null from user data");
                //TODO segfault?
                return paContinue;
            }

            float* _out = cast(float*) outputBuffer;
            size_t samplesNeeded = framesPerBuffer * CHANNELS;

            size_t buffLen = Math.min(samplesNeeded, readBuffer.length);

            size_t samplesRead = player.buffer.read(readBuffer[0 .. buffLen]);

            if (samplesRead > 0)
            {
                _out[0 .. samplesRead] = readBuffer[0 .. samplesRead];
                if (samplesRead < samplesNeeded)
                {
                    _out[samplesRead .. samplesNeeded] = 0.0f;
                }

                return paContinue;
            }

            _out[0 .. samplesNeeded] = 0.0f;
        }
        catch (Exception e)
        {
            import std.stdio : stderr;

            stderr.writeln(e);
        }

        return paContinue;
    }

    size_t calculateLat(Latency req)
    {
        final switch (req) with (Latency)
        {
            case lowLatency:
                return 256; // 5.8 ms
            case interactive:
                return 512; // 11.6 ms
            case standard:
                return 1024; // 23.2 ms
            case highStability:
                return 2048; // 46.4 ms
            case offline:
                return 4096; // 92.9 ms
        }
    }

}
