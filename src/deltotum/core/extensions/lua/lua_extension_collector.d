module deltotum.core.extensions.lua.lua_extension_collector;

import deltotum.core.contexts.context : Context;
import deltotum.core.configs.config : Config;
import deltotum.core.extensions.lua.lua_extension : LuaExtension;
import deltotum.core.extensions.extension_collector : ExtensionsCollector;

import std.logger : Logger;

import bindbc.lua;

class LuaExtensionCollector : ExtensionsCollector!LuaExtension
{
    const string extensionDir;
    const string extensionMainFile;
    const string extensionMainMethod;

    private
    {
        LuaSupport currentEnvironment;
    }

    this(Logger logger, Config config, Context context,
        string extensionDir, string extensionMainFile = "main.lua", string extensionMainMethod = "main")
    {
        super(logger, config, context);

        import std.exception : enforce;
        import std.format : format;
        import std.string : strip;
        import std.file : isDir, exists, isFile;

        enforce(extensionDir !is null && extensionDir.strip.length > 0,
            "Extensions directory must not be empty");
        if (!extensionDir.exists || !extensionDir.isDir)
        {
            throw new Exception("Extension directory not found: " ~ extensionDir);
        }
        this.extensionDir = extensionDir;

        enforce(extensionMainFile !is null && extensionMainFile.strip.length > 0,
            "Extensions main file must not be empty");
        this.extensionMainFile = extensionMainFile;

        enforce(extensionMainMethod !is null && extensionMainMethod.strip.length > 0,
            "Extensions main method must not be empty");
        this.extensionMainMethod = extensionMainMethod;
    }

    override void initialize()
    {
        super.initialize;

        import std.conv : to;
        import std.format : format;

        if (currentEnvironment)
        {
            throw new Exception(format("Lua environment already loaded: '%s'",
                    to!string(currentEnvironment)));
        }

        const LuaSupport luaResult = loadLua();
        if (luaResult != luaSupport)
        {
            if (luaResult == luaSupport.noLibrary)
            {
                throw new Exception("Lua shared library failed to load");
            }
            else if (luaResult == luaSupport.badLibrary)
            {
                throw new Exception("One or more Lua symbols failed to load");
            }

            throw new Exception(format("Couldn't load Lua environment, received lua load result: '%s'",
                    to!string(luaSupport)));
        }
        currentEnvironment = luaResult;
    }

    private string buildMainFile(string extensionDirName) @safe pure nothrow const
    {
        import std.path : buildPath;

        const mainFilePath = buildPath(extensionDirName, extensionMainFile);
        return mainFilePath;
    }

    override bool load()
    {
        import std.file : dirEntries, DirEntry, SpanMode, exists, isFile;
        import std.path : baseName;
        import std.format : format;

        foreach (DirEntry extensionFile; dirEntries(extensionDir, SpanMode.shallow))
        {
            if (!extensionFile.isDir)
            {
                continue;
            }

            const mainFilePath = buildMainFile(extensionFile);
            if (!mainFilePath.exists || !mainFilePath.isFile)
            {
                throw new Exception(format("Not found main file for extension path: %s",
                        mainFilePath));
            }

            const name = baseName(extensionFile);
            auto extension = new LuaExtension(logger, config, context, name, mainFilePath, extensionMainMethod);

            import std.algorithm.searching : canFind;

            const isDuplicated = canFind!((LuaExtension a,
                    LuaExtension b) => a.filePath == b.filePath)(extensions,
                extension);
            if (isDuplicated)
            {
                import std.format : format;

                throw new Exception(format("Extension already loaded from path: %s",
                        extension.filePath));
            }

            extensions ~= extension;
        }

        return extensions.length > 0;
    }
}
