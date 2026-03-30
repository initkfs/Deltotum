#!/usr/bin/env dub
/+ dub.sdl:

+/

import std;

immutable
{
    string hlslExt = ".hlsl";
}

void main(string[] args)
{
    string shaderFile;
    bool isCompileAll;
    auto cli = getopt(
        args,
        "f", &shaderFile,
        "a", &isCompileAll);

    if (!isCompileAll && shaderFile.length == 0)
    {
        stderr.writeln("Not found shader file");
        return;
    }

    string shadersDir = buildPath(getcwd, "data", "shaders");
    string shadersSrcDir = buildPath(shadersDir, "src");

    if (!isCompileAll)
    {
        auto shaderPath = shaderFile;
        if (!shaderPath.isAbsolute)
        {
            auto startExtIndex = shaderFile.indexOf(".");
            if (startExtIndex != -1)
            {
                shaderPath = buildPath(shadersSrcDir, shaderFile[0 .. startExtIndex], shaderFile)
                    .absolutePath;
            }
        }

        compileShader(shaderPath, shadersDir);
        return;
    }

    foreach (string dirFile; dirEntries(shadersSrcDir, SpanMode.depth))
    {
        if (!dirFile.isFile)
        {
            continue;
        }

        compileShader(dirFile, shadersDir, isVerbose:
            false);
    }
}

void compileShader(string shaderFile, string shadersDir, bool isVerbose = true)
{
    string shaderCrossArgs = "-s HLSL -t ";

    static const types = [".frag": "fragment", ".vert": "vertex"];
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

    shaderCrossArgs ~= mustBeShaderType;

    string sdl3Path = buildPath(getcwd, "libs", "sdl3");
    string shaderInFile = shaderFile;
    if (!shaderFile.endsWith(hlslExt))
    {
        shaderInFile ~= hlslExt;
    }

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

    string compileCmd = i"export LD_LIBRARY_PATH=$(sdl3Path):$LD_LIBRARY_PATH && shadercross $(shaderInFile) $(shaderCrossArgs) -e main -d SPIRV -o $(shaderOutFile)"
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
        throw new Exception("Failed shader compilation");
    }

    if (!isVerbose)
    {
        writeln("Compiled: ", shaderOutFile);
    }
}
