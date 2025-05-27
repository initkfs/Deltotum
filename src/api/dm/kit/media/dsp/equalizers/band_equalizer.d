module api.dm.kit.media.dsp.equalizers.band_equalizer;

import api.dm.kit.media.dsp.signals.analog_signal : AnalogSignal;

import Math = api.math;

/**
 * Authors: initkfs
 */
class BandEqualizer
{
    size_t numFreqBands;

    size_t bandScale;
    double bandStartOffset = 0;
    double bandEndOffset = 0;

    void delegate() onUpdateStart;
    void delegate(AnalogSignal) onUpdate;
    void delegate() onUpdateEnd;

    void delegate(size_t, double, double) onUpdateIndexFreqStartEnd;

    //protected
    //{
    double[] bandValues;
    //}

    AnalogSignal delegate(size_t fftIndex) signalProvider;

    double sampleWindowSize = 0;
    double sampleRateHz = 0;

    this(double sampleWindowSize, double sampleRateHz, AnalogSignal delegate(size_t fftIndex) signalProvider, size_t numFregBands = 10, size_t bandScale = 1, double bandStartOffset = 0, double bandEndOffset = 0)
    {
        assert(sampleWindowSize > 0);
        this.sampleWindowSize = sampleWindowSize;

        assert(sampleRateHz > 0);
        this.sampleRateHz = sampleRateHz;

        assert(numFregBands > 0);
        this.numFreqBands = numFregBands;

        assert(signalProvider);
        this.signalProvider = signalProvider;

        this.bandStartOffset = bandStartOffset;
        this.bandEndOffset = bandEndOffset;
        this.bandScale = bandScale;

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

        size_t startIndexOffset = 0;

        const double df = sampleRateHz / sampleWindowSize;

        size_t maxEndIndex = cast(size_t)(sampleWindowSize / 2);
        if (bandEndOffset > 0)
        {
            maxEndIndex = cast(size_t)(bandEndOffset / df);
        }

        double bandWidth = 0;

        if (bandEndOffset > 0)
        {
            startIndexOffset = cast(size_t)(bandStartOffset / df);
            assert(bandEndOffset > bandStartOffset);

            //double totalBandwidth = bandEndOffset - bandStartOffset;
            //bandWidth = totalBandwidth / numFreqBands;
            bandWidth = (maxEndIndex - startIndexOffset) / numFreqBands;
            
        }
        else if (bandStartOffset > 0)
        {
            double fMax = sampleRateHz / 2.0;
            double effectiveWidth = (fMax - bandStartOffset) / numFreqBands;
            bandWidth = effectiveWidth / df;
            startIndexOffset = cast(size_t)(bandStartOffset / df);
        }
        else
        {
            bandWidth = (sampleWindowSize / 2 / bandScale) / cast(double) numFreqBands;
        }

        foreach (i, ref double v; bandValues)
        {
            size_t start = startIndexOffset + cast(size_t)(i * bandWidth);
            size_t end = startIndexOffset + cast(size_t)((i + 1) * bandWidth);

            if (i == numFreqBands - 1){
                end = maxEndIndex;
            }

            if (start >= maxEndIndex){
                break;
            }

            //TODO check start
            if (end > maxEndIndex)
            {
                import std.format : format;

                throw new Exception(format("Out of bounds array index: %s, max: %s", end, maxEndIndex));
            }

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
