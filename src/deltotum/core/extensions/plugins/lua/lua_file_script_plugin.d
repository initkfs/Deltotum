module deltotum.core.extensions.plugins.lua.lua_file_script_plugin;

import deltotum.core.extensions.plugins.lua.lua_plugin : LuaPlugin;
import deltotum.core.contexts.context : Context;
import deltotum.core.configs.config : Config;

import std.logger : Logger;
import std.variant: Variant;

import bindbc.lua;

class LuaFileScriptPlugin : LuaPlugin
{
    const string filePath;
    const string pluginMainMethod;
    const string pluginBasePathGlobalVarName = "extensionDir";

    this(Logger logger, Config config, Context context, string name, string filePath, string pluginMainMethod = "main")
    {
        super(logger, config, context, name);

        import std.exception : enforce;
        import std.string : strip;
        import std.file : isDir, exists, isFile;

        enforce(filePath !is null && filePath.strip.length > 0,
            "Plugin file path must not be empty");
        if (!filePath.exists || !filePath.isFile)
        {
            throw new Exception("Not found plugin file: " ~ filePath);
        }
        this.filePath = filePath;

        enforce(pluginMainMethod !is null && pluginMainMethod.strip.length > 0,
            "Plugin main method must not be empty");
        this.pluginMainMethod = pluginMainMethod;
    }

    override void call(string[] args, void delegate(Variant) onResult, void delegate(string) onError)
    {
        import std.conv : to;
        import std.format : format;

        lua_State* luaState = luaL_newstate();
        try
        {
            setState(luaState);

            import std.format : format;

            import std.path : dirName;
            import std.string : toStringz;

            //TODO check dot?
            const extensionBasePath = filePath.dirName;

            luaL_dostring(luaState, format("package.path = package.path .. ';%s/?.lua'", extensionBasePath)
                    .toStringz);

            const int luaFileLoadResult = luaL_loadfile(luaState, filePath.toStringz);
            if (luaFileLoadResult != LUA_OK && onError)
            {
                string luaError = getLastError(luaState);
                const string error = format("Couldn't load lua file, received code %d from %s with error: %s",
                    luaFileLoadResult, filePath, luaError);
                onError(error);
            }

            lua_pushstring(luaState, extensionBasePath.toStringz);
            lua_setglobal(luaState, pluginBasePathGlobalVarName.toStringz);

            const callLuaFileResult = lua_pcall(luaState, 0, 1, 0);
            if (callLuaFileResult != LUA_OK && onError)
            {
                const luaError = getLastError(luaState);
                const string error = format("Couldn't load Lua script, received code %d from %s with error: %s",
                    luaFileLoadResult, filePath, luaError);
                onError(error);
            }

            resetStack(luaState);

            lua_getglobal(luaState, pluginMainMethod.toStringz);
            //lua_pushstring(luaState, event.toStringz);
            lua_newtable(luaState);
            foreach (size_t i, arg; args)
            {
                size_t luaIndex = i + 1;
                lua_pushnumber(luaState, luaIndex);
                lua_pushstring(luaState, arg.toStringz);
                lua_rawset(luaState, -3);
            }

            const int callMainMethodResult = lua_pcall(luaState, 2, 1, 0);
            if (callMainMethodResult != LUA_OK && onError)
            {
                const luaError = getLastError(luaState);
                const string err = format(
                    "Couldn't run Lua script method '%s', received code %d from %s with error: %s",
                    pluginMainMethod, luaFileLoadResult, filePath, luaError);
                onError(err);
            }

            enum topStackIndex = -1;
            acceptResult(luaState, topStackIndex, onResult, onError);
            resetStack(luaState);
        }
        finally
        {
            lua_close(luaState);
        }
    }
}
