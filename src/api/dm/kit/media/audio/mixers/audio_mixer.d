module api.dm.kit.media.audio.sounds.audio_mixer;

import api.dm.kit.media.audio.streams.audio_stream : AudioStream;
import api.dm.kit.media.audio.mixers.mix_sound : MixSound, SoundHandle;

import core.atomic: atomicLoad, atomicStore;

import api.dm.lib.portaudio.native;
import api.math.geom3.vec3 : Vec3f;
import Math = api.math;

/**
 * Authors: initkfs
 */

class AudioMixer
{
    MixSound[] _sounds;

    //TODO for chans
    float volume = 1;

    SoundHandle play(MixSound sound)
    {
        const id = noactiveId;
        sound.playing = true;
        if (id < 0)
        {
            const nextId = _sounds.length;
            _sounds ~= sound;
            return nextId;
        }

        _sounds[id] = sound;
        return id;
    }

    SoundHandle play(float[] samples, float volume = 1.0f, bool loop = false)
    {
        MixSound sound;
        sound.samples = samples;
        sound.volume = volume;
        sound.loop = loop;
        sound.playing = true;

        return play(sound);
    }

    void play(MixSound[] sounds)
    {
        foreach (MixSound s; sounds)
        {
            play(s);
        }
    }

    bool isPlaying(SoundHandle id)
    {
        if (id >= _sounds.length)
        {
            return false;
        }

        return _sounds[id].playing;
    }

    void freeSounds()
    {
        foreach (ref MixSound sound; _sounds)
        {
            if (!sound.playing && sound.freeFunPtr)
            {
                sound.free;
                sound.freeFunPtr = null;
            }
        }
    }

    size_t playingCount()
    {
        size_t count;
        foreach (ref MixSound sound; _sounds)
        {
            if (sound.playing)
            {
                count++;
            }
        }

        return count;
    }

    bool isPlaying() => playingCount != 0;

    void reset(SoundHandle id)
    {
        sound(id) = MixSound.init;
    }

    ref MixSound sound(SoundHandle id)
    {
        if (id >= _sounds.length)
        {
            import std.format : format;

            throw new Exception(format("MixSound id '%d' overflow array length '%d'", id, _sounds
                    .length));
        }

        return _sounds[id];
    }

    ptrdiff_t noactiveId()
    {
        foreach (i, ref s; _sounds)
        {
            if (!s.playing)
            {
                return i;
            }
        }

        return -1;
    }

    void stop(SoundHandle handle)
    {
        sound(handle).playing = false;
    }

    size_t mix(float[] output, size_t chanCount, bool isClearBuffer = true)
    {
        if (output.length == 0 || chanCount == 0)
        {
            return 0;
        }

        if (output.length % chanCount != 0)
        {
            return 0;
        }

        if (!isPlaying)
        {
            return 0;
        }

        if (isClearBuffer)
        {
            output[] = 0;
        }

        size_t numFrames = output.length / chanCount;

        enum maxChans = 32;
        float[maxChans] tempBufferStatic = 0;
        float[] tempBuffer = (chanCount <= maxChans) ? tempBufferStatic[0 .. chanCount]
            : new float[chanCount];

        size_t maxFramesCount;

        foreach (ref sound; _sounds)
        {
            if (!sound.playing)
            {
                continue;
            }

            size_t framesCount;

            const framesInSound = sound.samples.length / chanCount;

            ptrdiff_t framesAvailable = framesInSound - sound.positionFrame;
            if (framesAvailable <= 0)
            {
                sound.positionFrame = 0;
                sound.playing = false;
                continue;
            }

            size_t framesToProcess = Math.min(numFrames, framesAvailable);

            foreach (frame; 0 .. framesToProcess)
            {
                writeToChan(sound, frame, output, tempBuffer, chanCount);
            }

            sound.positionFrame += framesToProcess;
            framesCount += framesToProcess;

            if (sound.positionFrame >= framesInSound)
            {
                if (sound.loop)
                {
                    sound.positionFrame = 0;

                    if (framesToProcess < numFrames)
                    {
                        size_t remainingFrames = numFrames - framesToProcess;

                        foreach (frame; 0 .. remainingFrames)
                        {
                            writeToChan(sound, frame, output, tempBuffer, chanCount);
                        }

                        sound.positionFrame += remainingFrames;
                        framesCount += remainingFrames;
                    }
                }
                else
                {
                    sound.playing = false;
                    sound.positionFrame = 0;
                }
            }

            if (framesCount > maxFramesCount)
            {
                maxFramesCount = framesCount;
            }
        }

        const samplesCount = maxFramesCount * chanCount;

        const float maxAmp = 0.95;
        foreach (i, ref v; output[0 .. samplesCount])
        {
            v = Math.clamp(v, -maxAmp, maxAmp);
        }

        return samplesCount;
    }

    private size_t writeToChan(ref MixSound sound, size_t frame, ref float[] output, ref float[] tempBuffer, size_t chanCount)
    {
        size_t frameIndex = frame * chanCount;

        switch (chanCount)
        {
            case 1:
                //float sample = sound.samples[frameIndex];
                //output[frameIndex] += sample * sound.volume * this.volume;
                break;

            case 2:
                /** 
                         Constant Power Panning
                         float angle = (sound.pan + 1.0f) * (PI / 4.0f); // 0 to π/2
                         float leftGain = sound.volume * cos(angle);
                         float rightGain = sound.volume * sin(angle);
                         
                         Linear Panning, clipping
                         float leftGain = sound.volume * (1.0f - Math.max(0.0f, sound.pan));
                         float rightGain = sound.volume * (1.0f + Math.min(0.0f, sound.pan));

                         Square root panning
                         float leftGain = sound.volume * sqrt(1.0f - sound.pan);
                         float rightGain = sound.volume * sqrt(1.0f + sound.pan);

                         or
                         float leftGain = sound.volume * (1.0f - sound.pan) * 0.5f;
                         float rightGain = sound.volume * (1.0f + sound.pan) * 0.5f;
                        */
                float leftGain = sound.volume * (1.0f - Math.max(0.0f, sound.pan));
                float rightGain = sound.volume * (1.0f + Math.min(0.0f, sound.pan));

                size_t posIndex = (sound.positionFrame + frame);
                if (posIndex > 0)
                {
                    posIndex--;
                }

                float sampleL = sound.samples[posIndex * chanCount];
                float sampleR = sound.samples[posIndex * chanCount + 1];

                //output[frameIndex] += sampleL * leftGain * this.volume;
                //output[frameIndex + 1] += sampleR * rightGain * this.volume;
                output[frameIndex] += sampleL * leftGain * this.volume;
                output[frameIndex + 1] += sampleR * rightGain * this.volume;
                break;
            default:
                import std.conv : text;

                throw new Exception("Not supported channels: " ~ text(chanCount));
                // tempBuffer[] = 0.0f;
                // distributeToChans(sample, sound, tempBuffer, chanCount);
                // for (size_t ch = 0; ch < chanCount; ch++)
                // {
                //     output[frame * chanCount + ch] += tempBuffer[ch];
                // }
                break;
        }

        return chanCount;
    }

    private void distributeToChans(float sample, ref MixSound sound, ref float[] channels, size_t chanCount)
    {
        channels[] = 0.0f;

        float masterAvg = (this.volume + this.volume) * 0.5f;

        switch (chanCount)
        {
            case 1:
                channels[0] = sample * sound.volume * masterAvg;
                break;

            case 2:
                channels[0] = sample * sound.volume * (1.0f - Math.max(0.0f, sound.pan)) * this
                    .volume;
                channels[1] = sample * sound.volume * (1.0f + Math.min(0.0f, sound.pan)) * this
                    .volume;
                break;
            default:
                import api.math.numericals.interp : lerp;

                float gainPerChannel = sound.volume / chanCount;
                float panStep = 2.0f / (chanCount - 1);
                for (size_t ch = 0; ch < chanCount; ch++)
                {
                    float channelPos = -1.0f + ch * panStep;
                    float distance = Math.abs(channelPos - sound.pan);
                    float panGain = 1.0f - Math.min(distance, 1.0f);
                    float channelMaster = lerp(this.volume, this.volume, (
                            channelPos + 1.0f) * 0.5f);
                    channels[ch] = sample * gainPerChannel * panGain * channelMaster;
                }
                break;
        }
    }

    void fromDist(ref float[2] output, Vec3f listenerPos, Vec3f listenerForward)
    {
        foreach (sound; _sounds)
        {
            if (!sound.playing)
                continue;

            Vec3f relativePos = sound.geomPosition - listenerPos;
            float distance = relativePos.length;

            // (inverse square law)
            float distanceAttenuation = 1.0f / (1.0f + distance * distance);

            Vec3f direction = relativePos.normalize;
            float dot = direction.dot(listenerForward);
            float angle = Math.acos(dot);

            // [-1, 1]
            float pan = Math.sin(angle);

            float leftGain = 0.5f * (1.0f - pan);
            float rightGain = 0.5f * (1.0f + pan);

            //float sample = getCurrentSample(sound);
            //output[0] += sample * leftGain * distanceAttenuation * sound.volume;
            //output[1] += sample * rightGain * distanceAttenuation * sound.volume;
        }
    }

}

unittest
{
    import std.math.operations : isClose;
    import std.conv : to;

    {
        MixSound sound1;
        sound1.samples = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1];
        MixSound sound2;
        sound2.samples = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2];

        auto mixer = new AudioMixer;
        auto sid1 = mixer.play(sound1);
        assert(sound1.positionFrame == 0);
        auto sid2 = mixer.play(sound2);
        assert(sound2.positionFrame == 0);

        float[] buffer = new float[6];
        auto res = mixer.mix(buffer, 2);
        assert(res == buffer.length);
        foreach (float v; buffer)
        {
            assert(isClose(v, 0.3), v.to!string);
        }
        assert(sound1.positionFrame == 0);
        assert(sound2.positionFrame == 0);
    }

    {
        //TODO ramaining chans
        MixSound sound1 = MixSound([0.1, 0.1, 0.1]);
        MixSound sound2 = MixSound([0.2, 0.2, 0.2, 0.2, 0.2]);

        auto mixer = new AudioMixer;
        mixer.play([sound1, sound2]);

        float[16] buff = 0;
        auto res = mixer.mix(buff[], 2);
        assert(res == 4);
        isClose(buff[0 .. res], [0.3, 0.3, 0.2, 0.2, 0, 0]);
    }

}
