#!/usr/bin/env dub
/+ dub.sdl:

+/
module tools.md_palette_generator;

import std;

void main(string[] args)
{
    if (args.length < 2)
    {
        stderr.writeln("Not found palette file");
        return;
    }

    auto file = args[1];
    if (!file.exists || !file.isFile)
    {
        stderr.writeln("Palette file is not a file ", file);
        return;
    }

    auto paletteFile = File(file);

    string[] colorKeys;

    foreach (line; paletteFile.byLine)
    {
        if (!line.startsWith("string"))
        {
            continue;
        }

        auto lineParts = line.split(" ");
        auto colorKey = lineParts[1].idup;
        colorKeys ~= colorKey;
    }

    writeColorIteratorFunc(colorKeys, (str) => write(str));
}

void writeColorIteratorFunc(string[] colorKeys, scope void delegate(const(char)[]) sink)
{
    sink("void onColor(scope bool delegate(string color, size_t colorIndex) onColorIsContinue) {
    size_t colorIndex;    
");

    foreach (color; colorKeys)
    {
        sink(i"    if(!onColorIsContinue($(color), colorIndex++)) return;\n".text);
    }
    sink("}");
}
