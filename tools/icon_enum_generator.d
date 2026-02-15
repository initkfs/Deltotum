#!/usr/bin/env dub
/+ dub.sdl:

+/
module tools.icon_enum_generator;

import std;

void main(string[] args)
{
    //TODO linux only
    if (args.length != 2)
    {
        stderr.writeln("Not found css font file");
        return;
    }

    auto filePath = args[1];
    if (!filePath.exists || !filePath.isFile)
    {
        stderr.writeln("CSS font file is not a file ", filePath);
        return;
    }

    auto file = File(filePath);

    string[] result;

    const linePrefix = ".bi-";
    const beforePrefix = "::before";
    const needSymbols = 4;

    string[] syms;
    foreach (line; file.byLine)
    {
        if (!line.startsWith(linePrefix))
        {
            continue;
        }

        line = line[linePrefix.length .. $];

        auto beforeIndex = line.indexOf(beforePrefix);
        if (beforeIndex < 0)
        {
            stderr.writeln("Invalid line: ", line);
            continue;
        }

        auto name = line[0 .. beforeIndex];
        string normName = name.replace("-", "_").to!string;

        if(normName[0].isDigit || normName == "cast" || normName == "union"){
            normName = "_" ~ normName;
        }

        line = line[(name.length + beforePrefix.length) .. $];

        auto commIndex = line.indexOf("\"");
        if (commIndex < 0)
        {
            stderr.writeln("Invalid end of line: ", line);
            continue;
        }

        line = line[(commIndex + 2).. commIndex + needSymbols + 2];
        auto uniString = format("\'\\U0000%s\'", line);
        syms ~= uniString;

        writefln("dchar %s = %s;", normName, uniString);
    }

    writeln;
    write("immutable dchar[] syms = [");
    foreach (i, ch; syms)
    {
        write(ch);
        if(i != syms.length - 1){
            write(',');
        }
    }

    writeln("];");

}
