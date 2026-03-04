module api.dm.kit.media.dsp.dsp_processor;

import api.core.utils.queues.ring_buffer_lf : RingBufferLF;
import api.core.components.units.services.loggable_unit : LoggableUnit;

import api.dm.kit.media.dsp.analog_signals : AnalogSignal;
import api.dm.kit.media.dsp.analyzers.analog_signal_analyzer : AnalogSignalAnalyzer;

import core.sync.mutex : Mutex;
import api.core.loggers.logging : Logging;

import Math = api.math;

/**
 * Authors: initkfs
 */
class DspProcessor(size_t SignalBufferSize, size_t SignalChannels = 1) : LoggableUnit
{
    AnalogSignalAnalyzer signalAnalyzer;

    size_t sampleWindowSize;
    size_t sampleSizeForChannels;

    AnalogSignal[] fftBuffer;

    float sampleFreq = 0;

    void delegate() onUpdateFTBuffer;

    this(shared Mutex m, AnalogSignalAnalyzer signalAnalyzer, float sampleFreq, size_t sampleWindowSize, Logging logger)
    {
        super(logger);

        assert(signalAnalyzer);
        this.signalAnalyzer = signalAnalyzer;

        assert(sampleFreq > 0);
        this.sampleFreq = sampleFreq;

        assert(sampleWindowSize > 0);
        this.sampleWindowSize = sampleWindowSize;

        sampleSizeForChannels = sampleWindowSize * SignalChannels;
        fftBuffer = new AnalogSignal[](sampleWindowSize / 2);
    }

    void process(float[] samples)
    {
        // if (SignalChannels != 1)
        // {
        //     size_t nextIndex;
        //     for (size_t i = 0; i < sampleSizeForChannels; i += SignalChannels)
        //     {
        //         if (i < SignalChannels)
        //         {
        //             continue;
        //         }
        //         //TODO multichannel
        //         auto leftValue = localSampleBuffer[i - SignalChannels];
        //         auto rightValue = localSampleBuffer[i - 1];

        //         localSampleBuffer[nextIndex] = (leftValue == rightValue) ? leftValue : (
        //             cast(SignalType)(
        //                 (leftValue + rightValue) / SignalChannels));

        //         nextIndex++;
        //     }
        // }

        signalAnalyzer.fftFull(sampleWindowSize, sampleFreq, samples, fftBuffer);

        if (onUpdateFTBuffer)
        {
            onUpdateFTBuffer();
        }
    }
}
