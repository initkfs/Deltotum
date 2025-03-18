module api.dm.com.audio.com_audio_mixer;

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.audio.com_audio_clip : ComAudioClip;
import api.dm.com.audio.com_audio_chunk : ComAudioChunk;

alias TrackFinishedCallback = extern (C) void function(int trackNum) nothrow @nogc;

alias MixerCallback = extern (C) void function(void* udata, ubyte* stream, int len) nothrow @nogc;

alias ComAudioDeviceId = uint;

enum ComAudioFormat
{
    none,
    s16,
    s32,
    f32
}

struct ComAudioSpec
{
    ComAudioFormat format = ComAudioFormat.s16;
    int channels = 2;
    int freq = 44100;
}

/**
 * Authors: initkfs
 */
interface ComAudioMixer
{
nothrow:

    void close();

    ComResult newHeapMusic(string path, out ComAudioClip clip);
    ComResult newHeapWav(string path, out ComAudioChunk buffer);

    ComResult getTracks(out int tracksCount);
    ComResult setTracks(int tracksCount);

    ComResult setPostCallback(MixerCallback callback, void* userdata);

    ComResult setOnTrackFinished(TrackFinishedCallback callback);
}
