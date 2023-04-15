module deltotum.core.extensions.lua.lua_extension;

import deltotum.core.contexts.context : Context;
import deltotum.core.configs.config : Config;
import deltotum.core.extensions.file_extension : FileExtension;

import std.logger : Logger;

import bindbc.lua;

class LuaExtension : FileExtension
{
    const string extensionMainMethod;
    const string extensionBasePathGlobalVarName = "extensionDir";

    this(Logger logger, Config config, Context context, string name, string filePath, string extensionMainMethod = "main")
    {
        super(logger, config, context, name, filePath);

        import std.exception : enforce;
        import std.string : strip;
        import std.file : isDir, exists, isFile;

        enforce(extensionMainMethod !is null && extensionMainMethod.strip.length > 0,
            "Extensions main method must not be empty");
        this.extensionMainMethod = extensionMainMethod;
    }

    private string getLastLuaError(lua_State* luaState) nothrow const
    {
        import std.conv : to;

        const error = to!string(lua_tostring(luaState, -1));
        return error;
    }

    private void resetLuaStack(lua_State* luaState) nothrow const
    {
        //const int stackSize = lua_gettop(luaState);
        //lua_pop(luaState, stackSize);
        lua_settop(luaState, 0);
    }

    override bool load()
    {
        //TODO lua_State?
        return true;
    }

    override string[] call(string event, string[] args)
    {
        import std.conv: to;
        import std.format: format;

        lua_State* luaState = luaL_newstate();
        try
        {
            luaL_openlibs(luaState);
            import std.format : format;

            import std.path : dirName;
            import std.string : toStringz;

            //TODO check dot?
            const extensionBasePath = filePath.dirName;

            luaL_dostring(luaState, format("package.path = package.path .. ';%s/?.lua'", extensionBasePath)
                    .toStringz);

            const int luaFileLoadResult = luaL_loadfile(luaState, filePath.toStringz);
            if (luaFileLoadResult != LUA_OK)
            {
                string error = getLastLuaError(luaState);
                throw new Exception(format("Couldn't load lua file, received code %d from %s with error: %s",
                        luaFileLoadResult, filePath, error));
            }

            lua_pushstring(luaState, extensionBasePath.toStringz);
            lua_setglobal(luaState, extensionBasePathGlobalVarName.toStringz);

            const callLuaFileResult = lua_pcall(luaState, 0, 1, 0);
            if (callLuaFileResult != LUA_OK)
            {
                const error = getLastLuaError(luaState);
                throw new Exception(format("Couldn't load Lua script, received code %d from %s with error: %s",
                        luaFileLoadResult, filePath, error));
            }

            resetLuaStack(luaState);

            lua_getglobal(luaState, extensionMainMethod.toStringz);
            lua_pushstring(luaState, event.toStringz);
            lua_newtable(luaState);
            foreach (size_t i, arg; args)
            {
                size_t luaIndex = i + 1;
                lua_pushnumber(luaState, luaIndex);
                lua_pushstring(luaState, arg.toStringz);
                lua_rawset(luaState, -3);
            }

            const int callMainMethodResult = lua_pcall(luaState, 2, 1, 0);
            if (callMainMethodResult != LUA_OK)
            {
                const error = getLastLuaError(luaState);
                throw new Exception(format(
                        "Couldn't run Lua script method '%s', received code %d from %s with error: %s",
                        extensionMainMethod, luaFileLoadResult, filePath, error));
            }

            if (!lua_istable(luaState, -1))
            {
                throw new Exception(format("Expected table, but invalid luaFileLoadResult received from script method '%s' and script file %s",
                        extensionMainMethod, filePath));
            }

            string[] scriptResult = [];
            const returnTableSize = lua_objlen(luaState, -1);
            if (returnTableSize == 0)
            {
                return scriptResult;
            }

            lua_pushnil(luaState);
            while (lua_next(luaState, 1) != 0)
            {
                const int index = -1;
                string stringValue = "";
                if (lua_isnumber(luaState, index))
                {
                    const double luaValue = to!double(lua_tonumber(luaState, index));
                    stringValue = to!string(luaValue);
                }
                else if (lua_isstring(luaState, index))
                {
                    stringValue = to!string(lua_tostring(luaState, index));
                }
                else
                {
                    const string typeName = to!(string)(lua_typename(luaState,
                            lua_type(luaState, index)));
                    throw new Exception(format(
                            "Expected invalid type '%s' from return table of script method '%s' and script file %s",
                            typeName, extensionMainMethod, filePath));
                }

                scriptResult ~= stringValue;
                lua_pop(luaState, 1);
            }

            resetLuaStack(luaState);
            return scriptResult;
        }
        finally
        {
            lua_close(luaState);
        }
    }
}
