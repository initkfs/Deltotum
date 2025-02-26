#!/usr/bin/env dub
/+ dub.sdl:

+/

import std;

void main(string[] args)
{
    enum sdlKeyCodeHeaders = "SDL_keycode.h";
    if (args.length < 2)
    {
        stderr.writeln("Not found keycode file ", sdlKeyCodeHeaders);
        return;
    }

    auto keyCodeFilePath = args[1];
    if (!keyCodeFilePath.exists || !keyCodeFilePath.isFile)
    {
        stderr.writeln("Keycode file is not a file ", keyCodeFilePath);
        return;
    }

    auto keyCodeFile = File(keyCodeFilePath);

    enum keyCodePrefix = "SDLK_";
    enum keyCodeDefine = "#define";

    enum minKeysCount = 100;

    string[] sdlkKeys;
    sdlkKeys.reserve(minKeysCount);
    string[] comKeys;
    comKeys.reserve(minKeysCount);
    string[] keysComments;
    keysComments.reserve(minKeysCount);

    foreach (keyCodeLine; keyCodeFile.byLine)
    {
        if (keyCodeLine.canFind(keyCodeDefine) && keyCodeLine.canFind(keyCodePrefix) && keyCodeLine.canFind(
                "/**"))
        {
            foreach (line; keyCodeLine.strip.splitter(' '))
            {
                if (!line.startsWith(keyCodePrefix))
                {
                    continue;
                }

                auto sdlkKey = line.idup;

                sdlkKeys ~= sdlkKey;

                auto comKey = sdlkKey.chompPrefix(keyCodePrefix).toLower;
                comKeys ~= "key_" ~ comKey;

                const commentPos = keyCodeLine.indexOf("/**");
                if(commentPos != -1){
                    auto comment = keyCodeLine[commentPos..$].idup;
                    if(comment.canFind("SDL_SCANCODE_TO_KEYCODE")){
                        comment = " ";
                    }
                    keysComments ~= comment;
                }
            }
        }
    }

    assert(comKeys.length == sdlkKeys.length, format("Sdlk keys len %s, com keys len %s", sdlkKeys.length, comKeys
            .length));
    assert(comKeys.length == keysComments.length, format("Com keys len %s, comments len %s", sdlkKeys.length, keysComments
            .length));

    writeComKeyCode(comKeys, keysComments, str => write(str));
    write("\n");
    writeKeySwitch(sdlkKeys, comKeys, str => write(str));
}

void writeComKeyCode(string[] keys, string[] comments, scope void delegate(const(char)[]) sink)
{
    assert(keys.length > 0);
    assert(keys.length == comments.length);

    size_t maxCommentPadding = keys.map!(s => s.length).maxElement;

    sink("enum ComKeyName : int
{\n");
    foreach (i, key; keys)
    {
        string comment = " ".repeat(maxCommentPadding - key.length).join ~ comments[i];
        sink(i"    $(key), $(comment)\n".text);
    }
    sink("}");
}

void writeKeySwitch(string[] sdlkKeys, string[] comKeys, scope void delegate(const(char)[]) sink)
{
    assert(sdlkKeys.length > 0);
    assert(sdlkKeys.length == comKeys.length);

    const string leftPadding = "    ";
    const string leftNestedPadding = leftPadding.repeat(2).join;

    sink("final switch (code)
{\n");
    foreach (i; 0 .. sdlkKeys.length)
    {
        sink(i"$(leftPadding)case $(sdlkKeys[i]):
$(leftNestedPadding)return ComKeyName.$(comKeys[i]);\n".text);
    }
    //     sink(i"$(leftPadding)default:
    // $(leftNestedPadding)return ComKeyName.UNKNOWN;
    // }".text);
    sink("}");
}
