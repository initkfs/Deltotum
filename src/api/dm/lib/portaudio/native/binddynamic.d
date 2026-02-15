module api.dm.lib.portaudio.native.binddynamic;

/**
 * Authors: initkfs
 */
import api.dm.lib.portaudio.native.types;
import api.core.utils.libs.dynamic_loader : DynamicLoader;

import std.stdint;
import core.stdc.config : c_long, c_ulong;

__gshared extern (C) nothrow
{
    const(PaVersionInfo*) function() Pa_GetVersionInfo;
    const(char*) function(PaError errorCode) Pa_GetErrorText;
    PaError function() Pa_Initialize;
    PaError function() Pa_Terminate;
    PaHostApiIndex function() Pa_GetDefaultHostApi;
    const(PaHostApiInfo)* function(PaHostApiIndex hostApi) Pa_GetHostApiInfo;
    const(PaHostErrorInfo)* function() Pa_GetLastHostErrorInfo;
    PaDeviceIndex function() Pa_GetDefaultInputDevice;
    PaDeviceIndex function() Pa_GetDefaultOutputDevice;
    const(PaDeviceInfo)* function(PaDeviceIndex device) Pa_GetDeviceInfo;
    PaError function(const(PaStreamParameters)* inputParameters, const(PaStreamParameters)* outputParameters, double sampleRate) Pa_IsFormatSupported;

    PaError function(PaStream** stream, const(PaStreamParameters*) inputParameters, const(PaStreamParameters*) outputParameters, double sampleRate, c_ulong framesPerBuffer, PaStreamFlags streamFlags, PaStreamCallback streamCallback, void* userData) Pa_OpenStream;
    PaError function(PaStream** stream, int numInputChannels, int numOutputChannels, PaSampleFormat sampleFormat, double sampleRate, c_ulong framesPerBuffer, PaStreamCallback streamCallback, void* userData) Pa_OpenDefaultStream;
    PaError function(PaStream* stream) Pa_CloseStream;
    PaError function(PaStream* stream) Pa_StartStream;
    PaError function(PaStream* stream) Pa_StopStream;
    PaError function(PaStream* stream) Pa_AbortStream;
    PaError function(PaStream* stream) Pa_IsStreamStopped;
    PaError function(PaStream* stream) Pa_IsStreamActive;
    const(PaStreamInfo)* function(PaStream* stream) Pa_GetStreamInfo;
    PaTime function(PaStream* stream) Pa_GetStreamTime;
    double function(PaStream* stream) Pa_GetStreamCpuLoad;
    PaError function(PaStream* stream, void* buffer, c_ulong frames) Pa_ReadStream;
    PaError function(PaStream* stream, const(void)* buffer, c_ulong frames) Pa_WriteStream;
    c_long function(PaStream* stream) Pa_GetStreamReadAvailable;
    c_long function(PaStream* stream) Pa_GetStreamWriteAvailable;
}

class PortAudioLib : DynamicLoader
{
    bool isInit;

    override void bindAll()
    {
        bind(&Pa_GetVersionInfo, "Pa_GetVersionInfo");
        bind(&Pa_GetErrorText, "Pa_GetErrorText");
        bind(&Pa_Initialize, "Pa_Initialize");
        bind(&Pa_Terminate, "Pa_Terminate");
        bind(&Pa_GetDefaultHostApi, "Pa_GetDefaultHostApi");
        bind(&Pa_GetHostApiInfo, "Pa_GetHostApiInfo");
        bind(&Pa_GetLastHostErrorInfo, "Pa_GetLastHostErrorInfo");
        bind(&Pa_GetDefaultInputDevice, "Pa_GetDefaultInputDevice");
        bind(&Pa_GetDefaultOutputDevice, "Pa_GetDefaultOutputDevice");
        bind(&Pa_GetDeviceInfo, "Pa_GetDeviceInfo");
        bind(&Pa_IsFormatSupported, "Pa_IsFormatSupported");

        bind(&Pa_OpenStream, "Pa_OpenStream");
        bind(&Pa_OpenDefaultStream, "Pa_OpenDefaultStream");
        bind(&Pa_CloseStream, "Pa_CloseStream");
        bind(&Pa_StartStream, "Pa_StartStream");
        bind(&Pa_StopStream, "Pa_StopStream");
        bind(&Pa_AbortStream, "Pa_AbortStream");
        bind(&Pa_IsStreamStopped, "Pa_IsStreamStopped");
        bind(&Pa_IsStreamActive, "Pa_IsStreamActive");
        bind(&Pa_GetStreamInfo, "Pa_GetStreamInfo");
        bind(&Pa_GetStreamTime, "Pa_GetStreamTime");
        bind(&Pa_GetStreamCpuLoad, "Pa_GetStreamCpuLoad");
        bind(&Pa_ReadStream, "Pa_ReadStream");
        bind(&Pa_WriteStream, "Pa_WriteStream");
        bind(&Pa_GetStreamReadAvailable, "Pa_GetStreamReadAvailable");
        bind(&Pa_GetStreamWriteAvailable, "Pa_GetStreamWriteAvailable");
    }

    version (Windows)
    {
        const(char)[][1] paths = [
            "libportaudio.dll"
        ];
    }
    else version (OSX)
    {
        const(char)[][1] paths = [
            "libportaudio.dylib"
        ];
    }
    else version (Posix)
    {
        const(char)[][1] paths = [
            "libportaudio.so"
        ];
    }
    else
    {
        const(char)[0][0] paths;
    }

    override const(char[][]) libPaths()
    {
        return paths;
    }

    override int libVersion()
    {
        return 19;
    }

    override string libVersionStr()
    {
        if (!Pa_GetVersionInfo)
        {
            throw new Exception("Lib bindings is null");
        }

        const PaVersionInfo* info = Pa_GetVersionInfo();
        import std.string : fromStringz;

        return info.versionText.fromStringz.idup;
    }

    void initialize()
    {
        if (isInit)
        {
            return;
        }

        assert(Pa_Initialize);

        auto res = Pa_Initialize();
        if (res != PaErrorCode.paNoError)
        {
            throw new Exception(errorNew(res));
        }

        isInit = true;
    }

    void close()
    {
        if (!isInit)
        {
            return;
        }

        const res = Pa_Terminate();
        if (res != PaErrorCode.paNoError)
        {
            throw new Exception(errorNew(res));
        }
        //TODO log;
    }

    string errorNew(PaError res)
    {
        assert(Pa_GetErrorText);

        import std.string : fromStringz;

        return Pa_GetErrorText(res).fromStringz.idup;
    }

    string deviceInfoNew()
    {
        auto devIndex = Pa_GetDefaultOutputDevice();
        if (devIndex == paNoDevice)
        {
            return null;
        }

        const(PaDeviceInfo)* dev = Pa_GetDeviceInfo(devIndex);
        if (!dev)
        {
            return null;
        }

        const PaHostApiInfo* hostApi = Pa_GetHostApiInfo(dev.hostApi);

        import std.string : fromStringz;
        import std.format : format;

        auto sampleRateHz = dev.defaultSampleRate;
        auto outChans = dev.maxOutputChannels;

        return format("dev: %s, host: %s, outchan: %s, rate: %sHz", dev.name.fromStringz.idup, hostApi ? hostApi
                .name.fromStringz.idup : null, outChans, sampleRateHz);
    }

}
