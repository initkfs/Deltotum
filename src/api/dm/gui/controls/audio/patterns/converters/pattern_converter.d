module api.dm.gui.controls.audio.patterns.converters.pattern_converter;

import api.dm.kit.media.synthesis.sound_pattern : SoundPattern;
import api.dm.kit.media.synthesis.music_notes : NoteType;
import api.dm.kit.media.synthesis.effect_synthesis : ADSR;

import std.file : exists, isFile;
import std.stdio: File;
import std.format: format, formattedRead;
import std.range.primitives: walkLength;
import std.array: split;

/**
 * Authors: initkfs
 */

class PatternConverter
{
    void load(string file, scope void delegate(size_t, SoundPattern[]) onPattern)
    {
        assert(onPattern);

        if (!file.exists || !file.isFile)
        {
            throw new Exception("Not a pattern file: " ~ file);
        }

        File loadFile = File(file);

        size_t lineIndex;
        foreach (line; loadFile.byLine)
        {
            SoundPattern[] patterns;

            if (line.walkLength == 0)
            {
                continue;
            }

            foreach (patternData; line.split(";"))
            {
                if (patternData.length == 0)
                {
                    continue;
                }

                double fc = 0, fm = 0, fmIndex = 0;
                int noteDur, isFxMul;

                formattedRead(patternData, "%d(%f,%f,%f)%d", noteDur, fc, fm, fmIndex, isFxMul);
                NoteType type = cast(NoteType) noteDur;

                patterns ~= SoundPattern(type, fc, fm, fmIndex, ADSR.init, cast(bool) isFxMul);
            }

            if (patterns.length > 0)
            {
                onPattern(lineIndex, patterns);
            }

            lineIndex++;
        }

    }

    void save(SoundPattern[][] patterns, string filePath)
    {
        import std.array: appender;

        string content;

        auto builder = appender(&content);

        foreach (patternLine; patterns)
        {
            foreach (p; patternLine)
            {
                builder ~= format("%d(%f,%f,%f)%d;", cast(int) p.noteType, p.freqHz, p.fmHz, p.fmIndex, cast(
                        int) p.isFcMulFm);
            }
            builder ~= "\n";
        }

        auto file = File(filePath, "w");
        file.write(builder.data);
    }

}
