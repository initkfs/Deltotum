module api.dm.kit.media.buffers.audio_buffer;

import api.core.utils.queues.ring_buffer_lf : RingBufferLF;

import api.dm.lib.portaudio.native;
import Math = api.math;
import core.stdc.config : c_long, c_ulong;

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
    SAMPLE_RATE = 44100,
    CHANNELS = 2,
    FRAMES_PER_BUFFER = 512,
    BUFFER_MS = 100, // 100 ms
    BUFFER_SAMPLES = 4096, //
    TOTAL_BYTES = BUFFER_SAMPLES * CHANNELS * float.sizeof
}

class AudioBuffer(size_t Size = TOTAL_BYTES, bool isStaticArray = false)
{
    //TODO shared
    __gshared RingBufferLF!(float, Size, isStaticArray, true) buffer;

    PaStream* _stream;
    bool _isPlaying;

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

    void start()
    {
        if (_isPlaying)
            return;

        PaStreamParameters outputParameters = {
            device: Pa_GetDefaultOutputDevice(),
            channelCount: CHANNELS,
            sampleFormat: paFloat32,
            suggestedLatency: Pa_GetDeviceInfo(
                Pa_GetDefaultOutputDevice()
            ).defaultHighOutputLatency,
            hostApiSpecificStreamInfo: null
        };

        auto err = Pa_OpenStream(
            &_stream,
            null, // no output
            &outputParameters,
            SAMPLE_RATE,
            FRAMES_PER_BUFFER,
            paClipOff,
            &audioCallback,
            cast(void*) this
        );

        if (err != PaErrorCode.paNoError)
        {
            throw new Exception("Failed to open audio stream: ", lastError(err));
            return;
        }

        err = Pa_StartStream(_stream);
        if (err != PaErrorCode.paNoError)
        {
            throw new Exception("Failed to start audio stream: ", lastError(err));
            return;
        }

        _isPlaying = true;
    }

    void stop()
    {
        if (!_isPlaying)
            return;

        if (_stream)
        {
            Pa_StopStream(_stream);
            Pa_CloseStream(_stream);
            _stream = null;
        }

        _isPlaying = false;
    }

    size_t writeAudio(float[] audioData)
    {
        if (!_isPlaying)
        {
            start();
        }
        auto count = buffer.write(audioData);
        return count;
    }

    size_t writeTestTone(float frequency, float durationSeconds)
    {
        size_t numSamples = cast(size_t)(SAMPLE_RATE * durationSeconds * CHANNELS);
        float[] tone = new float[numSamples];

        float phase = 0.0f;
        float phaseIncrement = 2.0f * 3.14159265f * frequency / SAMPLE_RATE;

        foreach (i; 0 .. numSamples / CHANNELS)
        {
            float sample = 0.8f * Math.sin(phase);

            tone[i * CHANNELS] = sample;
            tone[i * CHANNELS + 1] = sample;

            phase += phaseIncrement;
            if (phase > 2.0f * 3.14159265f)
            {
                phase -= 2.0f * 3.14159265f;
            }
        }

        return writeAudio(tone);
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
            AudioBuffer* player = cast(AudioBuffer*) userData;

            float* _out = cast(float*) outputBuffer;
            size_t samplesNeeded = framesPerBuffer * CHANNELS;

            size_t buffLen = Math.min(samplesNeeded, readBuffer.length);

            size_t samplesRead = player.buffer.read(readBuffer[0..buffLen]);

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

    void close()
    {
        if (_stream)
        {
            Pa_CloseStream(_stream);
        }
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
