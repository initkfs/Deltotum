module api.dm.kit.media.dsp.dsp_processor;

import api.core.utils.queues.ring_buffer_spsc : RingBuffer;
import api.core.components.units.services.loggable_unit : LoggableUnit;

import api.dm.kit.media.dsp.analog_signals : AnalogSignal;
import api.dm.kit.media.dsp.analog_signals : AnalogSignal;
import DspWinFunc = api.dm.kit.media.dsp.analog_signals;

import core.sync.mutex : Mutex;

import Math = api.math;

/**
 * Authors: initkfs
 */
class DspProcessor(size_t SignalBufferSize, size_t SignalChannels = 1, size_t SampleWindowSize = 512)
{
    size_t sampleWindowSize;

    __gshared RingBuffer!(AnalogSignal, SampleWindowSize * 1024) fftQueue;
    AnalogSignal[] fftBuffer;

    float sampleFreq = 0;

    void delegate() onUpdateFTBuffer;
    float[] localSampleBuffer;

    this(shared Mutex m, float sampleFreq, size_t sampleWindowSize)
    {
        assert(sampleFreq > 0);
        this.sampleFreq = sampleFreq;

        assert(sampleWindowSize > 0);
        this.sampleWindowSize = sampleWindowSize;

        fftBuffer = new AnalogSignal[](sampleWindowSize / 2);

        fftQueue.initialize;
    }

    void process(float[] samples)
    {
        if (samples.length == 0)
        {
            return;
        }

        if (SignalChannels != 1)
        {
            if (localSampleBuffer.length != (samples.length / SignalChannels))
            {
                //TODO correct size;
                localSampleBuffer = new float[](samples.length / SignalChannels);
            }

            localSampleBuffer[] = 0;

            for (size_t i = 0; i < localSampleBuffer.length; i++)
            {
                //TODO multichannel
                size_t sampleIndex = i * SignalChannels;
                float leftValue = samples[sampleIndex];
                float rightValue = samples[sampleIndex + 1];

                localSampleBuffer[i] = (leftValue == rightValue) ? leftValue : (
                    (
                        (leftValue + rightValue) / SignalChannels));
            }

            fft(sampleWindowSize, sampleFreq, localSampleBuffer, fftBuffer);
        }
        else
        {
            fft(sampleWindowSize, sampleFreq, samples, fftBuffer);
        }

        auto writeSize = fftQueue.write(fftBuffer);
    }

    bool fft(size_t windowSize, float signalFreq, float[] samples, AnalogSignal[] outBuffer)
    {
        if (samples.length == 0)
        {
            return false;
        }

        import std.math.traits : isPowerOf2;

        if (!isPowerOf2(samples.length))
        {
            import std.conv : to;
            import std.stdio : writeln, stderr;

            // throw new Exception("Samples length must be power of 2, but received: " ~ samples.length.to!string);
            stderr.writeln("Samples length must be power of 2, but received: ", samples
                    .length.to!string);
            return false;
        }

        DspWinFunc.hann(samples);

        const halfWinSize = windowSize / 2;
        if (halfWinSize != outBuffer.length)
        {
            import std.conv : to;
            import std.stdio : writeln, stderr;
            import std.format : format;

            stderr.writeln(format("Output buffer must be window size / 2 == %d, but received: %d", halfWinSize, outBuffer
                    .length));
            return false;
        }

        import std.numeric : fft;

        auto fftRes = fft(samples[0 .. halfWinSize]);
        const fftResLen = fftRes.length;

        if (fftResLen > halfWinSize)
        {
            import std.stdio : stderr, writeln;

            stderr.writeln("FFT size overflow");
            return false;
        }

        foreach (i; 0 .. halfWinSize)
        {
            auto fftVal = fftRes[i];
            //fftVal.re = fftVal.re / fftResLen;
            //fftVal.im = fftVal.im / fftResLen;

            float magn = Math.sqrt(fftVal.re * fftVal.re + fftVal.im * fftVal.im);
            //magn = Math.clamp(magn, -1.0, 1.0);

            //length = length / (sampleWindowSize / 2)
            float freq = i * signalFreq / fftResLen;
            outBuffer[i] = AnalogSignal(freq, magn);
        }

        return true;
    }
}
