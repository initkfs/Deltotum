module api.dm.addon.dsp.dsp_processor;

import api.core.utils.adt.rings.ring_buffer : RingBuffer;
import api.core.components.units.services.loggable_unit : LoggableUnit;

import api.dm.addon.dsp.signals.analog_signal : AnalogSignal;
import api.dm.addon.dsp.analyzers.analog_signal_analyzer : AnalogSignalAnalyzer;

import core.sync.mutex : Mutex;
import api.core.loggers.logging : Logging;

import Math = api.math;

/**
 * Authors: initkfs
 */
class DspProcessor(SignalType, size_t SignalBufferSize, size_t SignalChannels = 1) : LoggableUnit
{
    AnalogSignalAnalyzer signalAnalyzer;

    RingBuffer!(SignalType, SignalBufferSize) dspBuffer;

    size_t sampleWindowSize;
    size_t sampleSizeForChannels;

    SignalType[] localSampleBuffer;

    AnalogSignal[] fftBuffer;

    double sampleFreq = 0;

    void delegate() onUpdateFTBuffer;

    this(shared Mutex m, AnalogSignalAnalyzer signalAnalyzer, double sampleFreq, size_t sampleWindowSize, Logging logger)
    {
        super(logger);

        assert(signalAnalyzer);
        this.signalAnalyzer = signalAnalyzer;

        assert(sampleFreq > 0);
        this.sampleFreq = sampleFreq;

        assert(sampleWindowSize > 0);
        this.sampleWindowSize = sampleWindowSize;

        sampleSizeForChannels = sampleWindowSize * SignalChannels;

        dspBuffer = newDspBuffer(m);
        dspBuffer.initialize(isFillInit : false);

        localSampleBuffer = new SignalType[](sampleSizeForChannels);
        fftBuffer = new AnalogSignal[](sampleWindowSize / 2);
    }

    typeof(dspBuffer) newDspBuffer(shared Mutex m) => typeof(dspBuffer)(m);

    static extern (C) void signal_callback(void* userdata, ubyte* stream, int len) nothrow @nogc
    {
        if (len == 0)
        {
            return;
        }

        auto dspBuffer = cast(typeof(dspBuffer)*) userdata;
        assert(dspBuffer);

        SignalType[] streamSlice = cast(SignalType[]) stream[0 .. len];

        try
        {
            import std.stdio : stderr, writefln;

            const writeRes = dspBuffer.writeIfNoBlockSync(streamSlice);
            if (!writeRes)
            {
                debug stderr.writefln("Warn, dsp buffer data loss: %s, reason: %s", len, writeRes);
            }
            else
            {
                // debug writefln("Write %s data to buffer, ri %s, wi %s, size: %s, result %s", len, dspBuffer.readIndex, dspBuffer
                //         .writeIndex, dspBuffer.size, writeRes);
            }
        }
        catch (Exception e)
        {
            import std.stdio : stderr, writeln;

            debug stderr.writeln("Exception from dsp thread: ", e.msg);
            //throw new Error("Exception from audio thread", e);
        }
    }

    void block()
    {
        dspBuffer.blockSync;
    }

    void unblock()
    {
        dspBuffer.unblockSync;
    }

    void step()
    {
        const readDspRes = dspBuffer.readIfNoBlockSync(localSampleBuffer[], sampleSizeForChannels);

        if (readDspRes)
        {
            // import std.stdio : writefln;

            // debug writefln("Receive data from buffer, ri %s, wi %s, size: %s", dspBuffer.readIndex, dspBuffer
            //         .writeIndex, dspBuffer.size);

            if (SignalChannels != 1)
            {
                size_t nextIndex;
                for (size_t i = 0; i < sampleSizeForChannels; i += SignalChannels)
                {
                    if (i < SignalChannels)
                    {
                        continue;
                    }
                    //TODO multichannel
                    auto leftValue = localSampleBuffer[i - SignalChannels];
                    auto rightValue = localSampleBuffer[i - 1];

                    localSampleBuffer[nextIndex] = (leftValue == rightValue) ? leftValue : (
                        cast(SignalType)(
                            (leftValue + rightValue) / SignalChannels));

                    nextIndex++;
                }
            }

            SignalType[] data = cast(SignalType[]) localSampleBuffer[0 .. sampleWindowSize];

            signalAnalyzer.fftFull(sampleWindowSize, sampleFreq, data, fftBuffer);

            if (onUpdateFTBuffer)
            {
                onUpdateFTBuffer();
            }
        }
        else
        {
            if (!readDspRes.isNoFilled && !readDspRes.isLocked && !readDspRes.isEmpty)
            {
                logger.warning("Warn. Cannot read from dsp buffer, reason: ", readDspRes);
                return;
            }
        }
    }

}
