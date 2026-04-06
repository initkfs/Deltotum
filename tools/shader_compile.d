#!/usr/bin/env dub
/+ dub.sdl:

+/

import std;

immutable
{
    string hlslExt = ".hlsl";
    string hlslExtInclude = hlslExt ~ "i";
}

void main(string[] args)
{
    string shaderFile;
    bool isCompileAll;

    auto cli = getopt(
        args,
        "a", &isCompileAll);

    if (!isCompileAll)
    {
        if (args.length < 2)
        {
            stderr.writeln("Not found shader file");
            return;
        }

        shaderFile = args[1];
    }

    string shadersDir = buildPath(getcwd, "data", "shaders");
    string shadersSrcDir = buildPath(shadersDir, "src");
    string startShaderCrossArgs = "-s HLSL -t ";
    static const types = [".frag": "fragment", ".vert": "vertex"];
    string sdl3Path = buildPath(getcwd, "libs", "sdl3");

    bool isVerbose = !isCompileAll;
    bool isCompile;

    foreach (string dirFile; dirEntries(shadersSrcDir, SpanMode.depth))
    {
        if (!dirFile.isFile || dirFile.endsWith(hlslExtInclude))
        {
            continue;
        }

        if (isCompileAll)
        {
            shaderFile = dirFile;
        }
        else
        {
            if (!dirFile.baseName.startsWith(shaderFile))
            {
                continue;
            }
        }

        string mustBeShaderType;
        foreach (fileType, shaderType; types)
        {
            if (canFind(shaderFile, fileType))
            {
                mustBeShaderType = shaderType;
                break;
            }
        }

        if (mustBeShaderType.length == 0)
        {
            throw new Exception("Not found shader type in " ~ shaderFile);
        }

        string shaderCrossArgs = startShaderCrossArgs;
        shaderCrossArgs ~= mustBeShaderType;

        string shaderInFile = dirFile;
        string shaderOutFile = buildPath(shadersDir, "out", "spirv");
        
        if (shaderFile.isAbsolute)
        {
            auto outName = shaderFile.baseName;
            if (outName.endsWith(hlslExt))
            {
                outName = outName.stripExtension;
            }
            shaderOutFile = buildPath(shaderOutFile, outName);
        }
        else
        {
            auto rawShaderName = shaderFile;
            if (shaderFile.endsWith(hlslExt))
            {
                rawShaderName = rawShaderName.stripExtension;
            }
            shaderOutFile = buildPath(shaderOutFile, rawShaderName);
        }

        shaderOutFile ~= ".spv";

        string compileCmd = i"export LD_LIBRARY_PATH=$(sdl3Path):$LD_LIBRARY_PATH && shadercross $(shaderInFile) $(shaderCrossArgs) -I $(shadersSrcDir) -e main -d SPIRV -o $(shaderOutFile)"
            .text;

        if (isVerbose)
        {
            writeln(compileCmd);
        }

        auto result = executeShell(compileCmd);
        if (result.output.length != 0)
        {
            writeln(result.output);
        }

        if (result.status != 0)
        {
            throw new Exception("Failed shader compilation: " ~ dirFile);
        }

        if (!isVerbose)
        {
            writeln("Compiled: ", shaderOutFile);
        }

        isCompile = true;
    }

    if (!isCompileAll && !isCompile)
    {
        stderr.writeln("Error. Target shader not found: ", shaderFile);
    }
}
