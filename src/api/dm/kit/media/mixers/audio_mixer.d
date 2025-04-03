module api.dm.kit.media.mixers.audio_mixer;

import api.dm.com.audio.com_audio_mixer : ComAudioMixer;
import api.dm.com.audio.com_audio_clip : ComAudioClip;

class AudioMixer
{

    //private
    // {
    ComAudioMixer mixer;
    //}

    this(ComAudioMixer mixer)
    {
        assert(mixer);
        this.mixer = mixer;
    }

    bool isPlaying(int channel)
    {
        assert(mixer);
        return mixer.isPlaying(channel);
    }

    ComAudioClip newClip(string path)
    {
        ComAudioClip newClip;
        if (const err = mixer.newHeapMusic(path, newClip))
        {
            throw new Exception(err.toString);
        }
        return newClip;
    }
}
