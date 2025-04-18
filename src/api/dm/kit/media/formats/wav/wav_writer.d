module api.dm.kit.media.formats.wav.wav_writer;

import api.dm.com.audio.com_audio_device : ComAudioSpec;

import std.stdio : File;
import std.file : isFile, exists;
import core.stdc.stdio;

/**
 * Authors: initkfs
 */

class WavWriter
{
    void save(T)(string path, T[] buffer, ComAudioSpec spec)
    {
        //TODO LE\BE?
        uint dataSize = cast(uint) (buffer.length * T.sizeof);

        auto file = File(path, "wb");

        //chunkId
        file.rawWrite("RIFF");

        uint[1] chunkSize = [36 + dataSize];
        file.rawWrite(chunkSize);

        //format
        file.rawWrite("WAVE");
        //subchunk1Id
        file.rawWrite("fmt ");

        uint[1] subchunk1Size = [16];
        file.rawWrite(subchunk1Size);

        ushort pcm = 1;
        ushort[1] audioFormat = [pcm];
        file.rawWrite(audioFormat);

        ushort numChans = cast(ushort) spec.channels;
        ushort[1] channels = [numChans];
        file.rawWrite(channels);

        uint sampleRateHz = cast(uint) spec.freqHz;
        uint[1] sampleRate = [sampleRateHz];
        file.rawWrite(sampleRate);

        uint byteRateCount = sampleRateHz * numChans * 2;
        uint[1] byteRate = [byteRateCount];
        file.rawWrite(byteRate);

        ushort[1] blockAlign = [cast(ushort) (numChans * 2)];
        file.rawWrite(blockAlign);

        ushort bitsPerSample;

        import api.dm.com.audio.com_audio_device : ComAudioFormat;

        final switch (spec.format) with (ComAudioFormat)
        {
            case s16, none:
                bitsPerSample = 16;
                break;
            case s32, f32:
                bitsPerSample = 32;
                break;
        }

        ushort[] bitsPerSamples = [bitsPerSample];
        file.rawWrite(bitsPerSamples);

        //subchunk2Id
        file.rawWrite("data");

        uint[1] subchunk2Size = [dataSize];
        file.rawWrite(subchunk2Size);

        //TODO check header size == 44

        file.rawWrite(buffer);
    }
}
