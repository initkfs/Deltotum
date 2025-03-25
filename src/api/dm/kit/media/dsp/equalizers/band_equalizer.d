module api.dm.kit.media.dsp.equalizers.band_equalizer;

import api.dm.kit.media.dsp.signals.analog_signal : AnalogSignal;

import Math = api.math;

/**
 * Authors: initkfs
 */
class BandEqualizer
{
    size_t numFreqBands;
    double bandWidth = 0;

    void delegate() onUpdateStart;
    void delegate(AnalogSignal) onUpdate;
    void delegate() onUpdateEnd;

    void delegate(size_t, double, double) onUpdateIndexFreqStartEnd;

    //protected
    //{
    double[] bandValues;
    //}

    AnalogSignal delegate(size_t fftIndex) signalProvider;

    this(double sampleWindowSize, AnalogSignal delegate(size_t fftIndex) signalProvider, size_t numFregBands = 10)
    {
        assert(numFregBands > 0);
        this.numFreqBands = numFregBands;

        assert(signalProvider);
        this.signalProvider = signalProvider;

        bandWidth = (sampleWindowSize / 2) / cast(double) numFreqBands;

        bandValues = new double[](numFreqBands);
        bandValues[] = 0;
    }

    void update()
    {
        bandValues[] = 0;

        if (onUpdateStart)
        {
            onUpdateStart();
        }

        foreach (i, ref double v; bandValues)
        {
            size_t start = cast(size_t)(i * bandWidth);
            size_t end = cast(size_t)((i + 1) * bandWidth);

            foreach (j; start .. end)
            {
                auto signal = signalProvider(j);
                auto magn = signal.magn;

                if (onUpdate)
                {
                    onUpdate(signal);
                }

                v += magn;
            }

            import std.format : format;
            import Math = api.math;

            if (onUpdateIndexFreqStartEnd)
            {
                auto startFreq = signalProvider(start).freqHz;
                auto endFreq = signalProvider(end - 1).freqHz;
                onUpdateIndexFreqStartEnd(i, startFreq, endFreq);
            }

            v /= bandWidth;
        }

        if (onUpdateEnd)
        {
            onUpdateEnd();
        }
    }

    double ampToDb(double amp)
    {
        import std.math : log10;

        return 20 * log10(amp == 0 ? double.epsilon : amp);
    }
}
