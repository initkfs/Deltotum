module deltotum.kit.extensions.plugins.julia.julia_script_text_plugin;

import deltotum.kit.extensions.plugins.julia.julia_plugin : JuliaPlugin;
import deltotum.core.contexts.context : Context;
import deltotum.core.configs.config : Config;

import std.logger : Logger;
import std.variant : Variant;

class JuliaScriptTextPlugin : JuliaPlugin
{
    bool isInit;

    this(Logger logger, Config config, Context context, const string name)
    {
        super(logger, config, context, name);
    }

    override void call(string[] args, void delegate(Variant) onResult, void delegate(string) onError)
    {
        import deltotum.sys.julia.libs;

        if (args.length == 0)
        {
            return;
        }

        import std.file : getcwd, chdir;

        auto lastCwd = getcwd;
        if (workDirPath)
        {
            chdir(workDirPath);
        }

        scope (exit)
        {
            if (workDirPath && workDirPath != lastCwd)
            {
                chdir(lastCwd);
            }
        }

        if (!isInit)
        {
            jl_init();
        }

        string content = args[0];

        import std.string : toStringz;

        auto resultPtr = jl_eval_string(content.toStringz);

        import std.string : fromStringz;

        if (onError)
        {
            if (auto errorPtr = jl_exception_occurred())
            {
                auto modPtr = cast(jl_module_t*) jl_eval_string("Base");
                auto showPtr = jl_get_function(modPtr, "showerror");
                assert(showPtr);
                auto sprintPtr = jl_get_function(modPtr, "sprint");
                assert(sprintPtr);
                auto sprintResPtr = jl_call2(sprintPtr, cast(jl_value_t*) showPtr, errorPtr);
                assert(sprintResPtr);
                auto errorTextPtr = jl_string_ptr(sprintResPtr);
                assert(errorTextPtr);
                onError(errorTextPtr.fromStringz.idup);
            }
        }

        if (onResult && resultPtr)
        {
            import std.conv : to;

            string result;
            const resultTypeStr = jl_typeof_str(resultPtr).fromStringz.idup;

            debug
            {
                import std.stdio : writeln;

                writeln("Julia script return type: ", resultTypeStr);
            }

            switch (resultTypeStr)
            {
            case "Bool":
                result = jl_unbox_bool(resultPtr).to!string;
                break;
            case "String":
                result = jl_string_ptr(resultPtr).fromStringz.idup;
                break;
            case "Int32":
                result = jl_unbox_int32(resultPtr).to!string;
                break;
            case "Int64":
                result = jl_unbox_int64(resultPtr).to!string;
                break;
            case "Float64":
                result = jl_unbox_float64(resultPtr).to!string;
                break;
            default:
                break;
            }

            import std.variant;

            Variant res = result;
            onResult(res);
        }

        chdir(lastCwd);
    }

    //TODO jl_atexit_hook(0);

}
