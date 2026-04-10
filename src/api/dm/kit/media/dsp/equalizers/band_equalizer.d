module api.dm.kit.media.dsp.equalizers.band_equalizer;

import api.dm.kit.media.dsp.analog_signals : AnalogSignal;

import Math = api.math;

/**
 * Authors: initkfs
 */
class BandEqualizer
{
    size_t numFreqBands;

    void delegate() onUpdateStart;
    void delegate(AnalogSignal) onUpdate;
    void delegate() onUpdateEnd;

    void delegate(size_t, float, float) onUpdateIndexFreqStartEnd;

    //protected
    //{
    float[] bandValues;
    //}

    AnalogSignal delegate(size_t fftIndex) signalProvider;

    float sampleWindowSize = 0;
    float sampleRateHz = 0;

    this(float sampleWindowSize, float sampleRateHz, AnalogSignal delegate(size_t fftIndex) signalProvider, size_t numFregBands = 10)
    {
        assert(sampleWindowSize > 0);
        this.sampleWindowSize = sampleWindowSize;

        assert(sampleRateHz > 0);
        this.sampleRateHz = sampleRateHz;

        assert(numFregBands > 0);
        this.numFreqBands = numFregBands;

        assert(signalProvider);
        this.signalProvider = signalProvider;

        bandValues = new float[](numFreqBands);
        bandValues[] = 0;
    }

    float minFreq = 20.0f;
    float maxFreq = 22050.0f;

    float minDB = -60.0f;
    float maxDB = 0f;

    void update()
    {
        bandValues[] = 0;

        if (onUpdateStart)
        {
            onUpdateStart();
        }

        size_t maxIndex = cast(size_t)(sampleWindowSize / 2);
        if (maxIndex > 0)
        {
            maxIndex--;
        }

        import Math = api.math;

        size_t numBands = bandValues.length;
        size_t lastEnd = 0;

        foreach (i, ref float v; bandValues)
        {
            float fEnd = minFreq * Math.pow(maxFreq / minFreq, cast(float)(i + 1) / numBands);
            size_t start = lastEnd;
            size_t end = cast(size_t) Math.round((fEnd * sampleWindowSize / 2) / sampleRateHz);
            if (end > maxIndex)
                end = maxIndex;
            if (end <= start)
                end = start + 1;

            size_t count = 0;
            float sum = 0;
            float sumSq = 0;
            foreach (j; start .. end)
            {
                if (j >= maxIndex)
                    break;

                auto signal = signalProvider(j);
                sum += signal.magn;
                sumSq += signal.magn * signal.magn;
                count++;
                if (onUpdate)
                    onUpdate(signal);
            }

            import std.math.exponential : log10;

            auto magnV = (count > 0) ? (sum / count) : 0;
            float rms = (count > 0) ? Math.sqrt(sumSq / count) : 0.0f;
            rms /= (sampleWindowSize / 2.0f);
            //Hann compensation
            rms *= 2.0; 

            float db = 20.0f * log10(rms + 0.000001f);
            float normalized = (db - minDB) / (maxDB - minDB);
            //normalized = pow(clamp01(normalized), 1.5f); 

            v = Math.clamp01(normalized);

            lastEnd = end;

            import std.format : format;
            import Math = api.math;

            if (onUpdateIndexFreqStartEnd)
            {
                auto startFreq = signalProvider(start).freqHz;
                auto endFreq = signalProvider(end).freqHz;
                onUpdateIndexFreqStartEnd(i, startFreq, endFreq);

                // import std;

                // writeln("Start index:", start, ", end: ", end, " Start freq hz:", startFreq, " end:", endFreq, " v: ", v);
            }

        }

        // float bandWidth = sampleWindowSize / 2 / 2 / numFreqBands;

        // size_t count;
        // foreach (i, ref float v; bandValues)
        // {
        //     size_t start = cast(size_t)(i * bandWidth);
        //     size_t end = cast(size_t)((i + 1) * bandWidth);

        //     if (end > maxIndex)
        //     {
        //         end = maxIndex;
        //     }

        //     foreach (j; start .. end)
        //     {
        //         auto signal = signalProvider(j);
        //         auto magn = signal.magn;

        //         if (onUpdate)
        //         {
        //             onUpdate(signal);
        //         }

        //         v += magn;
        //         count++;
        //     }

        //     if (count > 0)
        //     {
        //         v /= count;
        //     }

        //     float normalized = v / (sampleWindowSize / 2.0f);
        //     if (normalized < 0.00001)
        //     {
        //         normalized = 0;
        //     }
        //     else
        //     {
        //         normalized = Math.clamp(normalized * 500, 0.0f, 1.0f);
        //     }

        //     v = normalized;

        //     import std.format : format;
        //     import Math = api.math;

        //     if (onUpdateIndexFreqStartEnd)
        //     {
        //         auto startFreq = signalProvider(start).freqHz;
        //         auto endFreq = signalProvider(end).freqHz;
        //         onUpdateIndexFreqStartEnd(i, startFreq, endFreq);

        //         // import std;

        //         // writeln("Start index:", start, ", end: ", end, " Start freq hz:", startFreq, " end:", endFreq);
        //     }

        //     //     //v /= bandWidth;
        // }

        if (onUpdateEnd)
        {
            onUpdateEnd();
        }
    }

    float ampToDb(float amp)
    {
        import std.math.exponential : log10;

        return 20.0 * log10(amp + 1e-7);
    }

    double calculateRMSNorm(AnalogSignal[] samples, double startFreq, double endFreq)
    {
        import Math = api.math;

        if (samples.length == 0)
        {
            return 0;
        }

        size_t startIndex = cast(size_t)((startFreq * sampleWindowSize) / sampleRateHz);
        size_t endIndex = cast(size_t)((endFreq * sampleWindowSize) / sampleRateHz);

        if (startIndex > endIndex)
        {
            return 0;
        }

        if (endIndex >= samples.length)
        {
            endIndex = samples.length - 1;
        }

        double sumSq = 0.0;
        int count = 0;

        for (size_t i = startIndex; i <= endIndex; i++)
        {
            // abs for complex == sqrt(re^2 + im^2)
            double mag = samples[i].magn;
            // sin amplitude 1.0 ==  1.0
            sumSq += mag * mag;
            count++;
        }

        auto rms = (count > 0) ? Math.sqrt(sumSq / count) : 0;
        rms /= (sampleWindowSize / 2.0f);
        //Hann compensation
        rms *= 2.0; 
        //float smoothRMS = lerp(prevSmoothRMS, currentRMS, 0.2f); 
        return rms;
    }

    double calculateRMSNormDb(AnalogSignal[] samples, double startFreq, double endFreq)
    {
        import std.math.exponential : log10;

        auto rms = calculateRMSNorm(samples, startFreq, endFreq);
        auto db = (rms > 0) ? 20.0 * log10(rms) : -100.0;
        return db;
    }
}
