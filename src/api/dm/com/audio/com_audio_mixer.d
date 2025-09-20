module api.dm.com.audio.com_audio_mixer;

import api.dm.com.com_result : ComResult;
import api.dm.com.audio.com_audio_clip : ComAudioClip;
import api.dm.com.audio.com_audio_chunk : ComAudioChunk;
import api.dm.com.audio.com_audio_device;

alias TrackFinishedCallback = extern (C) void function(int trackNum) nothrow ;

alias MixerCallback = extern (C) void function(void* udata, ubyte* stream, int len) nothrow ;
alias MixerChannelFinishedCallback = extern (C) void function(int channel) nothrow ;

/**
 * Authors: initkfs
 */
interface ComAudioMixer
{
nothrow:

    void close();

    ComResult allocChannels(size_t count);

    ComResult newHeapMusic(string path, out ComAudioClip clip);
    ComResult newHeapWav(string path, out ComAudioChunk buffer);

    ComResult open(ComAudioDeviceId id, ComAudioSpec spec);

    ComResult getTracks(out int tracksCount);
    ComResult setTracks(int tracksCount);

    void stopChannel(int channel);

    bool isPlaying(int channel);
    bool isPlaying();

    bool fadeOut(int channel, int ms);

    ComResult setPostCallback(MixerCallback callback, void* userdata);
    ComResult setChannelCallback(MixerChannelFinishedCallback callback);
    ComResult setOnTrackFinished(TrackFinishedCallback callback);
}
