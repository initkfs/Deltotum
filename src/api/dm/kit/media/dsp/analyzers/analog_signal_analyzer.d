module api.dm.kit.media.dsp.analyzers.analog_signal_analyzer;

import api.dm.kit.media.dsp.analog_signals : AnalogSignal;
import DspWinFunc = api.dm.kit.media.dsp.analog_signals;

import Math = api.math;

/**
 * Authors: initkfs
 */
class AnalogSignalAnalyzer
{
    void fftFrames(size_t windowSize, float signalFreq, float[] samples, scope bool delegate(float, AnalogSignal[] fftBuffer) onFrameIsContinue)
    {
        size_t overlap = windowSize / 2;

        AnalogSignal[] fftBuffer = new AnalogSignal[](windowSize / 2);

        for (size_t i = 0; i < samples.length - windowSize; i += overlap)
        {
            float[] frame = samples[i .. i + windowSize];
            DspWinFunc.hann(frame);

            auto timeSec = i / signalFreq;
            fftBuffer[] = AnalogSignal.init;

            fft(windowSize, signalFreq, frame, fftBuffer);

            if (!onFrameIsContinue(timeSec, fftBuffer))
            {
                break;
            }
        }
    }

    bool fftFull(SignalType)(size_t windowSize, float signalFreq, SignalType[] samples, AnalogSignal[] outBuffer)
    {
        DspWinFunc.hann(samples);
        return fft(windowSize, signalFreq, samples, outBuffer);
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
            throw new Exception("Samples length must be power of 2");
        }

        const halfWinSize = windowSize / 2;
        if (halfWinSize != outBuffer.length)
        {
            import std.format : format;

            throw new Exception(format("Output buffer must be window size / 2 == %d, but received: %d", halfWinSize, outBuffer
                    .length));
        }

        import std.numeric : fft;

        auto fftRes = fft(samples);
        const fftResLen = fftRes.length;

        if (fftResLen > halfWinSize)
        {
            throw new Exception("FFT size overflow");
        }

        foreach (i; 0 .. halfWinSize)
        {
            auto fftVal = fftRes[i];
            //fftVal.re = fftVal.re / fftResLen;
            //fftVal.im = fftVal.im / fftResLen;

            float magn = Math.sqrt(fftVal.re * fftVal.re + fftVal.im * fftVal.im);

            magn = Math.clamp(magn, -1.0, 1.0);

            //length = length / (sampleWindowSize / 2)
            float freq = i * signalFreq / fftResLen;
            outBuffer[i] = AnalogSignal(freq, magn);
        }

        return true;
    }

}
