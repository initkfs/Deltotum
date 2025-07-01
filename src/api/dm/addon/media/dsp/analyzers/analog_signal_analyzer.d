module api.dm.addon.media.dsp.analyzers.analog_signal_analyzer;

import api.dm.addon.media.dsp.signals.analog_signal : AnalogSignal;
import DspWinFunc = api.dm.addon.media.dsp.signal_funcs;

import Math = api.math;

/**
 * Authors: initkfs
 */
class AnalogSignalAnalyzer
{
    void fftFrames(SignalType)(size_t windowSize, double signalFreq, SignalType[] samples, scope bool delegate(double, AnalogSignal[] fftBuffer) onFrameIsContinue)
    {
        size_t overlap = windowSize / 2;

        AnalogSignal[] fftBuffer = new AnalogSignal[](windowSize / 2);

        for (size_t i = 0; i < samples.length - windowSize; i += overlap)
        {
            SignalType[] frame = samples[i .. i + windowSize];
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

    bool fftFull(SignalType)(size_t windowSize, double signalFreq, SignalType[] samples, AnalogSignal[] outBuffer)
    {
        DspWinFunc.hann(samples);
        return fft(windowSize, signalFreq, samples, outBuffer);
    }

    bool fft(SignalType)(size_t windowSize, double signalFreq, SignalType[] samples, AnalogSignal[] outBuffer)
    {
        import std.math.traits : isPowerOf2;

        assert(isPowerOf2(samples.length));

        if (samples.length == 0)
        {
            return false;
        }

        const halfWinSize = windowSize / 2;

        assert(halfWinSize <= outBuffer.length);

        import std.numeric : fft;

        auto fftRes = fft(samples);
        const fftResLen = fftRes.length;

        assert(halfWinSize <= fftResLen);

        foreach (i; 0 .. halfWinSize)
        {
            auto fftVal = fftRes[i];
            //fftVal.re = fftVal.re / fftResLen;
            //fftVal.im = fftVal.im / fftResLen;

            double magnitude = Math.sqrt(fftVal.re * fftVal.re + fftVal.im * fftVal.im);

            magnitude = Math.clamp(magnitude, 0, SignalType.max) / SignalType.max;

            auto magnMax = SignalType.max;
            if (magnitude > magnMax)
            {
                import std.stdio : stderr, writefln;

                stderr.writefln("Warn. Signal magnitude %s exceeds the maximum value %s", magnitude, magnMax);
            }

            //magnitude = magnitude / (sampleWindowSize / 2)
            double freq = i * signalFreq / fftResLen;
            outBuffer[i] = AnalogSignal(freq, magnitude);
        }

        return true;
    }

}
