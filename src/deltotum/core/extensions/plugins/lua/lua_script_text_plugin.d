module deltotum.core.extensions.plugins.lua.lua_script_text_plugin;

version (ExtensionLua)
{
    import deltotum.core.extensions.plugins.lua.lua_plugin : LuaPlugin;
    import deltotum.core.contexts.context : Context;
    import deltotum.core.configs.config : Config;

    import std.logger : Logger;
    import std.variant : Variant;

    import bindbc.lua;

    class LuaScriptTextPlugin : LuaPlugin
    {
        this(Logger logger, Config config, Context context, const string name)
        {
            super(logger, config, context, name);
        }

        override void call(string[] args, void delegate(Variant) onResult, void delegate(string) onError)
        {
            call(args, null, onResult, onError);
        }

        void call(string[] args, void delegate(lua_State*) onState, void delegate(Variant) onResult, void delegate(
                string) onError)
        {
            if (args.length == 0)
            {
                return;
            }

            const string scriptContent = args[0];

            import std.conv : to;
            import std.format : format;
            import std.string : toStringz;

            lua_State* luaState = luaL_newstate();
            try
            {
                if (onState)
                {
                    onState(luaState);
                }

                setState(luaState);

                const scriptResult = luaL_dostring(luaState, scriptContent.toStringz);
                if (scriptResult && onError)
                {
                    string error = getLastError(luaState);
                    onError(error);
                    return;
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
}
