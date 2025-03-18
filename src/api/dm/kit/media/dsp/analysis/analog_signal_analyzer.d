module api.dm.kit.media.dsp.analysis.analog_signal_analyzer;

import api.dm.kit.media.dsp.signals.analog_signal : AnalogSignal;

import api.dm.addon.math.geom2.triangulations.fortune;

import Math = api.math;

/**
 * Authors: initkfs
 */
class AnalogSignalAnalyzer
{

    bool fft(SignalType)(size_t windowSize, double signalFreq, SignalType[] samples, AnalogSignal[] outBuffer)
    {
        if (samples.length == 0)
        {
            return false;
        }

        const halfWinSize = windowSize;

        assert(halfWinSize < outBuffer.length);
        assert(halfWinSize >= samples.length);

        import std.numeric : fft;

        auto fftRes = fft(samples);
        const fftResLen = fftRes.length;

        foreach (i; 0 .. halfWinSize)
        {
            auto fftVal = fftRes[i];
            double magnitude = Math.sqrt(fftVal.re * fftVal.re + fftVal.im * fftVal.im);
            //magnitude = magnitued / (sampleWindowSize / 2)
            double freq = i * (signalFreq / fftResLen);
            outBuffer[i] = AnalogSignal(freq, magnitude);
        }

        return true;
    }

}
