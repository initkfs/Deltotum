module api.dm.kit.media.audio.streams.audio_stream;

import api.core.utils.queues.ring_buffer_spsc : RingBuffer;
import api.dm.kit.media.audio.streams.audio_spec : AudioFormat, AudioSpec;

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

enum AudioStreamState
{
    none,
    open,
    start,
    stop,
    close
}

class AudioStream(size_t Size, size_t FramesPerBuffer, size_t Channels)
{
    AudioSpec spec;
    //TODO shared
    __gshared RingBuffer!(float, Size, false, true) buffer;

    __gshared double callbackTimeSec = 0;
    __gshared double callbackTimeDACSec = 0;
    __gshared size_t callbackFramesCount;

    //FIXME bug without static?
    static shared size_t frameClock;

    protected
    {
        __gshared PaStream* _stream;

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

    bool isStart() => atomicLoad(_state) == AudioStreamState.start;
    bool isStop() => atomicLoad(_state) == AudioStreamState.stop;

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
            ).defaultLowOutputLatency,
            hostApiSpecificStreamInfo: null
        };

        auto err = Pa_OpenStream(
            &_stream,
            null, // no input
            &outputParameters,
            spec.freqHz,
            FramesPerBuffer,
            0,
            &audioCallback,
            cast(void*) this
        );

        if (err != PaErrorCode.paNoError)
        {
            throw new Exception("Failed to open audio stream: ", lastError(err));
        }

        atomicStore(_state, AudioStreamState.open);
    }

    void start()
    {
        if (isStart)
        {
            return;
        }

        if (atomicLoad(_state) == AudioStreamState.none)
        {
            open;
        }

        if (_stream)
        {
            auto err = Pa_StartStream(_stream);
            if (err != PaErrorCode.paNoError)
            {
                throw new Exception("Failed to start audio stream: ", lastError(err));
            }
        }

        atomicStore(_state, AudioStreamState.start);
    }

    void stop()
    {
        if (isStop)
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

    double streamTimeSec()
    {
        if (_stream && isStart)
        {
            return Pa_GetStreamTime(_stream); // - Pa_GetStreamOutputLatency(_stream);
        }

        return 0;
    }

    double streamLatencySec()
    {
        //TODO cache
        if (_stream && isStart)
        {
            return Pa_GetStreamInfo(_stream).outputLatency;
        }

        return 0;
    }

    size_t writeSine(float[] audioData, float soundHz = 440.0, float freqHz = 44100)
    {
        size_t totalFrames = audioData.length / 2;
        double phase = 0.0;
        double increment = 2.0 * Math.PI * soundHz / freqHz;
        for (size_t i = 0; i < totalFrames; i++)
        {
            float sample = Math.sin(phase) * 0.5f;
            audioData[i * 2] = sample;
            audioData[i * 2 + 1] = sample;
            phase += increment;
        }

        return writeAudio(audioData);
    }

    size_t writeAudio(float[] audioData)
    {
        return buffer.write(audioData);
    }

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

            if (statusFlags != 0)
            {
                //TODO log
                import std.stdio : writeln;

                if (statusFlags & paInputOverflow)
                {
                    writeln("Input_overflow");
                }

                if (statusFlags & paOutputUnderflow)
                {
                    writeln("Output underflow");
                }

                if (statusFlags & PaErrorCode.paInternalError)
                {
                    writeln("Internal audio driver error");
                    return paAbort;
                }
            }

            double callbackTime = 0;
            double callbackDACTime = 0;
            if (timeInfo)
            {
                callbackTime = timeInfo.currentTime;
                callbackDACTime = timeInfo.outputBufferDacTime;
            }

            atomicStore(player.callbackTimeSec, callbackTime);
            atomicStore(player.callbackTimeDACSec, callbackDACTime);

            float* _out = cast(float*) outputBuffer;
            size_t samplesNeeded = framesPerBuffer * Channels;

            float[] outBuff = _out[0 .. samplesNeeded];

            if (!player)
            {
                import std.stdio : stderr;

                stderr.writeln("Audio stream is null from user data");
                //TODO segfault?
                outBuff[] = 0;
                return paContinue;
            }

            size_t samplesRead = player.buffer.read(outBuff);

            if (samplesRead < samplesNeeded)
            {
                outBuff[samplesRead .. $] = 0.0f;
            }

            //or samplesNeeded?
            if (samplesRead > 0)
            {
                import core.atomic : atomicOp;

                atomicOp!("+=")(player.frameClock, samplesNeeded / Channels);
            }

            return paContinue;
        }
        catch (Exception e)
        {
            import std.stdio : stderr;

            stderr.writeln(e);
        }

        //TODO segfault without filling
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
