module api.dm.kit.media.mixers.audio_mixer;

import api.dm.kit.media.buffers.audio_buffer : AudioBuffer;
import api.dm.kit.media.mixers.sound : Sound, SoundHandle;

import api.dm.lib.portaudio.native;
import api.math.geom3.vec3 : Vec3f;
import Math = api.math;

/**
 * Authors: initkfs
 */

class AudioMixer
{
    Sound[] _sounds;

    //TODO for chans
    float volume = 1;

    SoundHandle play(Sound sound)
    {
        const id = noactiveId;
        sound.active = true;
        sound.playing = true;
        if (id < 0)
        {
            const nextId = _sounds.length;
            _sounds ~= sound;
            return nextId;
        }

        reset(id);
        _sounds[id] = sound;
        return id;
    }

    SoundHandle play(float[] samples, float volume = 1.0f, bool loop = false)
    {
        Sound sound;
        sound.samples = samples;
        sound.volume = volume;
        sound.loop = loop;
        sound.playing = true;
        sound.active = true;

        return play(sound);
    }

    void play(Sound[] sounds)
    {
        foreach (Sound s; sounds)
        {
            play(s);
        }
    }

    bool isPlaying()
    {
        foreach (ref Sound sound; _sounds)
        {
            if (sound.playing)
            {
                return true;
            }
        }

        return false;
    }

    void reset(SoundHandle id)
    {
        sound(id) = Sound.init;
    }

    ref Sound sound(SoundHandle id)
    {
        if (id >= _sounds.length)
        {
            import std.format : format;

            throw new Exception(format("Sound id '%d' overflow array length '%d'", id, _sounds
                    .length));
        }

        return _sounds[id];
    }

    ptrdiff_t noactiveId()
    {
        foreach (i, s; _sounds)
        {
            if (!s.active)
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

    float[] mixToBuf(size_t frames, size_t chanCount = 2, bool isClearBuffer = true)
    {
        float[] buff = new float[frames * chanCount];
        if (!mix(buff, chanCount, isClearBuffer))
        {
            throw new Exception("Mixer error");
        }
        return buff;
    }

    bool mix(ref float[] output, size_t chanCount, bool isClearBuffer = true)
    {
        if (output.length == 0 || chanCount == 0)
        {
            return false;
        }

        if (output.length % chanCount != 0)
        {
            output[] = 0;
            return false;
        }

        size_t numFrames = output.length / chanCount;

        enum maxChans = 32;
        float[maxChans] tempBufferStatic;
        float[] tempBuffer = (chanCount <= maxChans) ? tempBufferStatic[0 .. chanCount]
            : new float[chanCount];

        if (isClearBuffer)
        {
            output[] = 0;
        }

        foreach (ref sound; _sounds)
        {
            if (!sound.playing || !sound.active)
            {
                continue;
            }

            ptrdiff_t framesAvailable = (sound.samples.length - sound.position) / chanCount;
            if (framesAvailable <= 0)
            {
                //throw new Exception("Samples negative");
                sound.position = 0;
                sound.playing = false;
                sound.active = false;
                continue;
            }

            size_t framesToProcess = Math.min(numFrames, framesAvailable);

            for (size_t frame = 0; frame < framesToProcess; frame++)
            {
                float sample = sample(sound, frame);
                writeToChan(sound, frame, sample, output, tempBuffer, chanCount);
            }

            sound.position += framesToProcess;

            if (sound.position >= sound.samples.length)
            {
                if (sound.loop)
                {
                    sound.position = 0;

                    if (framesToProcess < numFrames)
                    {
                        size_t remainingFrames = numFrames - framesToProcess;

                        for (size_t frame = 0; frame < remainingFrames; frame++)
                        {
                            float sample = sample(sound, frame);
                            writeToChan(sound, frame, sample, output, tempBuffer, chanCount);
                        }

                        sound.position += remainingFrames;
                    }
                }
                else
                {
                    sound.playing = false;
                }
            }
        }

        for (size_t i = 0; i < output.length; i++)
        {
            output[i] = Math.clamp(output[i], -1.0f, 1.0f);
        }

        return true;
    }

    private void writeToChan(ref Sound sound, size_t frame, float sample, ref float[] output, ref float[] tempBuffer, size_t chanCount)
    {
        switch (chanCount)
        {
            case 1:
                output[frame] += sample * sound.volume * this.volume;
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

                output[frame * 2] += sample * leftGain * this.volume;
                output[frame * 2 + 1] += sample * rightGain * this.volume;
                break;

            default:
                tempBuffer[] = 0.0f;
                distributeToChans(sample, sound, tempBuffer, chanCount);
                for (size_t ch = 0; ch < chanCount; ch++)
                {
                    output[frame * chanCount + ch] += tempBuffer[ch];
                }
                break;
        }
    }

    private float sample(ref Sound sound, size_t frameOffset = 0)
    {
        float exactPosition = sound.position + frameOffset;
        size_t integerPos = cast(size_t) exactPosition;
        float fraction = exactPosition - integerPos;

        if (integerPos >= sound.samples.length)
        {
            if (sound.loop)
            {
                // wrap around
                integerPos %= sound.samples.length;
            }
            else
            {
                return 0.0f;
            }
        }

        float current = sound.samples[integerPos];
        size_t nextPos = integerPos + 1;
        if (nextPos >= sound.samples.length)
        {
            if (sound.loop)
            {
                nextPos = 0;
            }
            else
            {
                return current;
            }
        }

        float next = sound.samples[nextPos];

        // Linear interpolation
        return current * (1.0f - fraction) + next * fraction;
    }

    private void distributeToChans(float sample, ref Sound sound, ref float[] channels, size_t chanCount)
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
        Sound sound1;
        sound1.samples = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1];
        Sound sound2;
        sound2.samples = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2];

        auto mixer = new AudioMixer;
        auto sid1 = mixer.play(sound1);
        assert(sound1.position == 0);
        auto sid2 = mixer.play(sound2);
        assert(sound2.position == 0);

        float[] buffer = new float[6];
        auto res = mixer.mix(buffer, 2);
        assert(res);
        foreach (float v; buffer)
        {
            assert(isClose(v, 0.3), v.to!string);
        }
        assert(sound1.position == 0);
        assert(sound2.position == 0);
    }

    {
        Sound sound1 = Sound([0.1, 0.1, 0.1]);
        Sound sound2 = Sound([0.2, 0.2, 0.2, 0.2, 0.2]);

        auto mixer = new AudioMixer;
        mixer.play([sound1, sound2]);

        auto res = mixer.mixToBuf(3, 2);
        assert(res.length == 6);
        isClose(res, [0.3, 0.3, 0.2, 0.2, 0, 0]);
    }

}
