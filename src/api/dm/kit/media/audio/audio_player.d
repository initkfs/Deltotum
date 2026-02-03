module api.dm.kit.media.audio.audio_player;

import api.dm.kit.media.mixers.audio_mixer : AudioMixer;
import api.dm.kit.media.buffers.audio_buffer : AudioBuffer;
import api.dm.kit.media.mixers.sound : Sound, SoundHandle;

/**
 * Authors: initkfs
 */

class AudioPlayer
{
    AudioBuffer!(4096 * 2 * float.sizeof) buffer;
    AudioMixer mixer;

    this()
    {
        buffer = new typeof(buffer);
        buffer.create;
        mixer = new AudioMixer;
    }

    SoundHandle play(Sound sound)
    {
        const sid = mixer.play(sound);
        float[] samples = new float[512 * 2];
        while (mixer.isPlaying)
        {
            mixer.mix(samples, 2, true);
            buffer.writeAudio(samples);
        }
        buffer.start;
        return sid;
    }
}
