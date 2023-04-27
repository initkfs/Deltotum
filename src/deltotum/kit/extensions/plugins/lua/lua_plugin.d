module deltotum.kit.extensions.plugins.lua.lua_plugin;

import deltotum.kit.extensions.plugins.plugin : Plugin;
import deltotum.core.contexts.context : Context;
import deltotum.core.configs.config : Config;

import std.logger : Logger;

import std.variant : Variant;

import bindbc.lua;

abstract class LuaPlugin : Plugin
{
    this(Logger logger, Config config, Context context, const string name)
    {
        super(logger, config, context, name);
    }

    protected string getLastError(lua_State* luaState) nothrow const
    {
        import std.conv : to;

        const error = lua_tostring(luaState, -1).to!string;
        return error;
    }

    protected void resetStack(lua_State* luaState) nothrow const
    {
        //const int stackSize = lua_gettop(luaState);
        //lua_pop(luaState, stackSize);
        lua_settop(luaState, 0);
    }

    protected void setState(lua_State* luaState)
    {
        luaL_openlibs(luaState);
        luaL_dostring(luaState, "package.path = package.path .. ';%s/?.lua'");
    }

    protected void acceptResult(lua_State* luaState, int index, void delegate(Variant) onResult, void delegate(
            string) onError)
    {
        import std.conv : to;
        import std.variant : Variant;

        Variant result = getValueFromStack(luaState, index, onError);
        if (result.hasValue && onResult)
        {
            onResult(result);
        }
    }

    protected Variant getValueFromStack(lua_State* luaState, int index, void delegate(string) onError)
    {
        import std.conv : to;
        import std.variant : Variant;

        Variant result;
        if (lua_isnumber(luaState, index))
        {
            result = lua_tonumber(luaState, index);
        }
        else if (lua_isstring(luaState, index))
        {
            result = lua_tostring(luaState, index).to!string;
        }
        else if (lua_isboolean(luaState, index))
        {
            result = lua_toboolean(luaState, index).to!bool;
        }
        else if (lua_isnil(luaState, index))
        {
            result = null;
        }
        else if (lua_istable(luaState, index))
        {
            const returnTableSize = lua_objlen(luaState, index);
            if (returnTableSize > 0)
            {
                Variant[] array;
                lua_pushnil(luaState);
                while (lua_next(luaState, 1) != 0)
                {
                    Variant tableResult = getValueFromStack(luaState, index, onError);
                    if (tableResult.hasValue)
                    {
                        array ~= tableResult;
                    }
                    lua_pop(luaState, 1);
                }

                if (array.length > 0)
                {
                    result = array;
                }
            }

        }
        else
        {
            if (onError)
            {
                import std.format : format;

                const int type = lua_type(luaState, index);
                const string typeName = lua_typename(luaState, type).to!(string);
                const string error = format(
                    "Unable to determine value from stack at index %s: unknown type '%s'",
                    index, typeName);
                onError(error);
            }
        }
        return result;
    }
}
