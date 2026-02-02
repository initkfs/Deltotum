module api.dm.lib.portaudio.native.types;
/**
 * Authors: initkfs
 */

import std.stdint;
import core.stdc.config : c_long, c_ulong;

struct PaStream;

struct PaVersionInfo
{
    int versionMajor;
    int versionMinor;
    int versionSubMinor;
    const char* versionControlRevision;
    const char* versionText;
}

alias PaError = int;
alias PaDeviceIndex = int;

enum PaDeviceIndex paNoDevice = -1;

alias PaHostApiIndex = int;
alias PaTime = double;

alias PaSampleFormat = c_ulong;

enum paFloat32 = (cast(PaSampleFormat) 0x00000001) /**< @see PaSampleFormat */ ;
enum paInt32 = (cast(PaSampleFormat) 0x00000002) /**< @see PaSampleFormat */ ;
enum paInt24 = (cast(PaSampleFormat) 0x00000004) /**< Packed 24 bit format. @see PaSampleFormat */ ;
enum paInt16 = (cast(PaSampleFormat) 0x00000008) /**< @see PaSampleFormat */ ;
enum paInt8 = (cast(PaSampleFormat) 0x00000010) /**< @see PaSampleFormat */ ;
enum paUInt8 = (cast(PaSampleFormat) 0x00000020) /**< @see PaSampleFormat */ ;
enum paCustomFormat = (cast(PaSampleFormat) 0x00010000) /**< @see PaSampleFormat */ ;
enum paNonInterleaved = (cast(PaSampleFormat) 0x80000000);

enum PaErrorCode
{
    paNoError = 0,

    paNotInitialized = -10000,
    paUnanticipatedHostError,
    paInvalidChannelCount,
    paInvalidSampleRate,
    paInvalidDevice,
    paInvalidFlag,
    paSampleFormatNotSupported,
    paBadIODeviceCombination,
    paInsufficientMemory,
    paBufferTooBig,
    paBufferTooSmall,
    paNullCallback,
    paBadStreamPtr,
    paTimedOut,
    paInternalError,
    paDeviceUnavailable,
    paIncompatibleHostApiSpecificStreamInfo,
    paStreamIsStopped,
    paStreamIsNotStopped,
    paInputOverflowed,
    paOutputUnderflowed,
    paHostApiNotFound,
    paInvalidHostApi,
    paCanNotReadFromACallbackStream,
    paCanNotWriteToACallbackStream,
    paCanNotReadFromAnOutputOnlyStream,
    paCanNotWriteToAnInputOnlyStream,
    paIncompatibleStreamHostApi,
    paBadBufferPtr,
    paCanNotInitializeRecursively
}

enum PaHostApiTypeId
{
    paInDevelopment = 0, /* use while developing support for a new host API */
    paDirectSound = 1,
    paMME = 2,
    paASIO = 3,
    paSoundManager = 4,
    paCoreAudio = 5,
    paOSS = 7,
    paALSA = 8,
    paAL = 9,
    paBeOS = 10,
    paWDMKS = 11,
    paJACK = 12,
    paWASAPI = 13,
    paAudioScienceHPI = 14,
    paAudioIO = 15,
    paPulseAudio = 16,
    paSndio = 17
}

struct PaHostApiInfo
{
    /** this is struct version 1 */
    int structVersion;
    /** The well known unique identifier of this host API @see PaHostApiTypeId */
    PaHostApiTypeId type;
    /** A textual description of the host API for display on user interfaces. Encoded as UTF-8. */
    const(char)* name;

    /**  The number of devices belonging to this host API. This field may be
     used in conjunction with Pa_HostApiDeviceIndexToDeviceIndex() to enumerate
     all devices for this host API.
     @see Pa_HostApiDeviceIndexToDeviceIndex
    */
    int deviceCount;

    /** The default input device for this host API. The value will be a
     device index ranging from 0 to (Pa_GetDeviceCount()-1), or paNoDevice
     if no default input device is available.
    */
    PaDeviceIndex defaultInputDevice;

    /** The default output device for this host API. The value will be a
     device index ranging from 0 to (Pa_GetDeviceCount()-1), or paNoDevice
     if no default output device is available.
    */
    PaDeviceIndex defaultOutputDevice;

}

struct PaHostErrorInfo
{
    PaHostApiTypeId hostApiType; /**< the host API which returned the error code */
    c_long errorCode; /**< the error code returned */
    const(char)* errorText; /**< a textual description of the error if available (encoded as UTF-8), otherwise a zero-length C string */
}

struct PaDeviceInfo
{
    int structVersion; /**< this is struct version 2 */

    /** Human readable device name. Encoded as UTF-8. */
    const(char)* name;

    /** Host API index in the range 0 to (Pa_GetHostApiCount()-1). Note: this is a host API index, not a type id. */
    PaHostApiIndex hostApi;

    int maxInputChannels;
    int maxOutputChannels;

    /** Default latency values for interactive performance. */
    PaTime defaultLowInputLatency;
    PaTime defaultLowOutputLatency;
    /** Default latency values for robust non-interactive applications (eg. playing sound files). */
    PaTime defaultHighInputLatency;
    PaTime defaultHighOutputLatency;

    double defaultSampleRate = 0;
}

struct PaStreamParameters
{
    /** A valid device index in the range 0 to (Pa_GetDeviceCount()-1)
     specifying the device to be used or the special constant
     paUseHostApiSpecificDeviceSpecification which indicates that the actual
     device(s) to use are specified in hostApiSpecificStreamInfo.
     This field must not be set to paNoDevice.
    */
    PaDeviceIndex device;

    /** The number of channels of sound to be delivered to the
     stream callback or accessed by Pa_ReadStream() or Pa_WriteStream().
     It can range from 1 to the value of maxInputChannels in the
     PaDeviceInfo record for the device specified by the device parameter.
    */
    int channelCount;

    /** The sample format of the buffer provided to the stream callback,
     Pa_ReadStream() or Pa_WriteStream(). It may be any of the formats described
     by the PaSampleFormat enumeration.
    */
    PaSampleFormat sampleFormat;

    /** The desired latency in seconds. Where practical, implementations should
     configure their latency based on these parameters. Implementations should
     round the actual latency up to the next viable value, except when suggested
     latency exceeds the upper limit for the device.

     Actual latency values for an open stream may be retrieved using the
     inputLatency and outputLatency fields of the PaStreamInfo structure
     returned by Pa_GetStreamInfo().
     @see default*Latency in PaDeviceInfo, *Latency in PaStreamInfo
    */
    PaTime suggestedLatency;

    /** An optional pointer to a host api specific data structure
     containing additional information for device setup and/or stream processing.
     hostApiSpecificStreamInfo is never required for correct operation,
     if not used it should be set to NULL.
    */
    void* hostApiSpecificStreamInfo;

}

alias PaStreamFlags = c_ulong;

/** @see PaStreamFlags */
enum paNoFlag = (cast(PaStreamFlags) 0);

/** Disable default clipping of out of range samples.
 @see PaStreamFlags
*/
enum paClipOff = (cast(PaStreamFlags) 0x00000001);

/** Disable default dithering.
 @see PaStreamFlags
*/
enum paDitherOff = (cast(PaStreamFlags) 0x00000002);

/** Flag requests that where possible a full duplex stream will not discard
 overflowed input samples without calling the stream callback. This flag is
 only valid for full duplex callback streams and only when used in combination
 with the paFramesPerBufferUnspecified (0) framesPerBuffer parameter. Using
 this flag incorrectly results in a paInvalidFlag error being returned from
 Pa_OpenStream() and Pa_OpenDefaultStream().

 @see PaStreamFlags, paFramesPerBufferUnspecified
*/
enum paNeverDropInput = (cast(PaStreamFlags) 0x00000004);

/** Call the stream callback to fill initial output buffers, rather than the
 default behavior of priming the buffers with zeros (silence). This flag has
 no effect for input-only and blocking read/write streams.

 @see PaStreamFlags
*/
enum paPrimeOutputBuffersUsingStreamCallback = (cast(PaStreamFlags) 0x00000008);

/** A mask specifying the platform specific bits.
 @see PaStreamFlags
*/
enum paPlatformSpecificFlags = (cast(PaStreamFlags) 0xFFFF0000);

/**
 Timing information for the buffers passed to the stream callback.

 Time values are expressed in seconds and are synchronised with the time base used by Pa_GetStreamTime() for the associated stream.

 @see PaStreamCallback, Pa_GetStreamTime
*/
struct PaStreamCallbackTimeInfo
{
    PaTime inputBufferAdcTime; /**< The time when the first sample of the input buffer was captured at the ADC input */
    PaTime currentTime; /**< The time when the stream callback was invoked */
    PaTime outputBufferDacTime; /**< The time when the first sample of the output buffer will output the DAC */
}

alias PaStreamCallbackFlags = c_ulong;

/** In a stream opened with paFramesPerBufferUnspecified, indicates that
 input data is all silence (zeros) because no real data is available. In a
 stream opened without paFramesPerBufferUnspecified, it indicates that one or
 more zero samples have been inserted into the input buffer to compensate
 for an input underflow.
 @see PaStreamCallbackFlags
*/
enum paInputUnderflow = (cast(PaStreamCallbackFlags) 0x00000001);

/** In a stream opened with paFramesPerBufferUnspecified, indicates that data
 prior to the first sample of the input buffer was discarded due to an
 overflow, possibly because the stream callback is using too much CPU time.
 Otherwise indicates that data prior to one or more samples in the
 input buffer was discarded.
 @see PaStreamCallbackFlags
*/
enum paInputOverflow = (cast(PaStreamCallbackFlags) 0x00000002);

/** Indicates that output data (or a gap) was inserted, possibly because the
 stream callback is using too much CPU time.
 @see PaStreamCallbackFlags
*/
enum paOutputUnderflow = (cast(PaStreamCallbackFlags) 0x00000004);

/** Indicates that output data will be discarded because no room is available.
 @see PaStreamCallbackFlags
*/
enum paOutputOverflow = (cast(PaStreamCallbackFlags) 0x00000008);

/** Some of all of the output data will be used to prime the stream, input
 data may be zero.
 @see PaStreamCallbackFlags
*/
enum paPrimingOutput = (cast(PaStreamCallbackFlags) 0x00000010);

/**
 Allowable return values for the PaStreamCallback.
 @see PaStreamCallback
*/
enum PaStreamCallbackResult
{
    paContinue = 0, /**< Signal that the stream should continue invoking the callback and processing audio. */
    paComplete = 1, /**< Signal that the stream should stop invoking the callback and finish once all output samples have played. */
    paAbort = 2 /**< Signal that the stream should stop invoking the callback and finish as soon as possible. */
}

alias paContinue = PaStreamCallbackResult.paContinue;
alias paComplete = PaStreamCallbackResult.paComplete;
alias paAbort = PaStreamCallbackResult.paAbort;

alias PaStreamCallback = extern(C) int function(
    const(void*) input, 
    void* output,
    c_ulong frameCount,
    const(PaStreamCallbackTimeInfo*) timeInfo,
    PaStreamCallbackFlags statusFlags,
    void* userData);

struct PaStreamInfo {
    /** this is struct version 1 */
    int structVersion;

    /** The input latency of the stream in seconds. This value provides the most
     accurate estimate of input latency available to the implementation. It may
     differ significantly from the suggestedLatency value passed to Pa_OpenStream().
     The value of this field will be zero (0.) for output-only streams.
     @see PaTime
    */
    PaTime inputLatency;

    /** The output latency of the stream in seconds. This value provides the most
     accurate estimate of output latency available to the implementation. It may
     differ significantly from the suggestedLatency value passed to Pa_OpenStream().
     The value of this field will be zero (0.) for input-only streams.
     @see PaTime
    */
    PaTime outputLatency;

    /** The sample rate of the stream in Hertz (samples per second). In cases
     where the hardware sample rate is inaccurate and PortAudio is aware of it,
     the value of this field may be different from the sampleRate parameter
     passed to Pa_OpenStream(). If information about the actual hardware sample
     rate is not available, this field will have the same value as the sampleRate
     parameter passed to Pa_OpenStream().
    */
    double sampleRate = 0;

}