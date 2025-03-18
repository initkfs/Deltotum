module api.dm.kit.media.dsp.dsp_processor;

import api.core.utils.structs.rings.ring_buffer : RingBuffer;
import api.core.components.units.services.loggable_unit : LoggableUnit;

import api.dm.kit.media.dsp.signals.analog_signal : AnalogSignal;
import api.dm.kit.media.dsp.analysis.analog_signal_analyzer : AnalogSignalAnalyzer;

import core.sync.mutex : Mutex;
import api.core.loggers.logging : Logging;

import DspWinFunc = api.dm.kit.media.dsp.window_funcs;

import Math = api.math;

/**
 * Authors: initkfs
 */
class DspProcessor(SignalType, size_t SignalBufferSize) : LoggableUnit
{
    AnalogSignalAnalyzer signalAnalyzer;

    RingBuffer!(SignalType, SignalBufferSize) dspBuffer;

    size_t sampleWindowSize;
    SignalType[SignalBufferSize] localSampleBuffer;

    AnalogSignal[SignalBufferSize / 2] fftBuffer;

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

        dspBuffer = newDspBuffer(m);
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

        short[] streamSlice = cast(short[]) stream[0 .. len];
        try
        {
            import std.stdio : writefln;

            const writeRes = dspBuffer.writeIfNoLockedSync(streamSlice);
            if (!writeRes)
            {
                debug writefln("Warn, dsp buffer data loss: %s, reason: %s", len, writeRes);
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

    void lock()
    {
        dspBuffer.lockSync;
    }

    void unlock()
    {
        dspBuffer.unlockSync;
    }

    void step()
    {
        const readDspRes = dspBuffer.readifNoLockedSync(localSampleBuffer[], sampleWindowSize);

        if (readDspRes)
        {
            // import std.stdio : writefln;

            // debug writefln("Receive data from buffer, ri %s, wi %s, size: %s", dspBuffer.readIndex, dspBuffer
            //         .writeIndex, dspBuffer.size);

            SignalType[] data = cast(SignalType[]) localSampleBuffer[0 .. sampleWindowSize];
            DspWinFunc.hann(data);

            signalAnalyzer.fft(sampleWindowSize, sampleFreq, data, fftBuffer);

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
