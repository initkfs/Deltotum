#!/usr/bin/env dub
/+ dub.sdl:

+/
module tools.sdl_scancode_converter;

import std;

void main(string[] args)
{
    enum sdlScanCodeHeaders = "SDL_scancode.h";
    if (args.length < 2)
    {
        stderr.writeln("Not found scancode file ", sdlScanCodeHeaders);
        return;
    }

    auto scanCodeFilePath = args[1];
    if (!scanCodeFilePath.exists || !scanCodeFilePath.isFile)
    {
        stderr.writeln("Scancode file is not a file ", scanCodeFilePath);
        return;
    }

    auto scanCodeFile = File(scanCodeFilePath);

    enum scanCodePrefix = "SDL_SCANCODE";

    string[] sdlCodes;
    sdlCodes.reserve(100);
    string[] comKeys;
    comKeys.reserve(100);

    foreach (scanCodeLine; scanCodeFile.byLine)
    {
        if (scanCodeLine.startsWith("/*") || !scanCodeLine.canFind(scanCodePrefix) || !scanCodeLine.canFind("="))
        {
            continue;
        }

        auto lineParts = scanCodeLine.chomp(",").idup.split("=");
        assert(lineParts.length >= 2, lineParts.to!string);

        auto scanKey = lineParts[0].strip;

        if (scanKey == "SDL_SCANCODE_COUNT")
        {
            continue;
        }

        sdlCodes ~= scanKey;

        auto scanValue = lineParts[1].strip;
        auto commaPos = scanValue.indexOf(",");
        if (commaPos != -1)
        {
            scanValue = scanValue[0 .. commaPos];
        }
        auto comKey = scanKey.toLower.chompPrefix("sdl_scan");
        auto comKeyAssign = format("%s = %s", comKey, scanValue);

        comKeys ~= comKeyAssign;
    }

    writeComScanCode(comKeys, str => write(str));
}

void writeComScanCode(string[] keys, scope void delegate(const(char)[]) sink)
{
    assert(keys.length > 0);

    sink("enum ComKeyScanCode : int
{\n");
    foreach (i, key; keys)
    {
        sink(i"    $(key),\n".text);
    }
    sink("}");
}
