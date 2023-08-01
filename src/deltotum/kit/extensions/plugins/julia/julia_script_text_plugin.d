module deltotum.kit.extensions.plugins.julia.julia_script_text_plugin;

import deltotum.kit.extensions.plugins.julia.julia_plugin : JuliaPlugin;
import deltotum.core.contexts.context : Context;
import deltotum.core.configs.config : Config;

import std.logger : Logger;
import std.variant : Variant;

import std.experimental.allocator;

struct JuliaCallback
{
    void* context;
    void* func;
}

class JuliaScriptTextPlugin : JuliaPlugin
{
    void delegate(void* buff, size_t sizeBytes) onCreateImage;

    protected
    {
        bool isInit;

        JuliaCallback callback;
    }

    void delegate(ubyte*, size_t) onBuff;

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
            //jl_gc_enable(0);

            import std.experimental.allocator : theAllocator;

            callback.context = cast(void*) this;
            callback.func = cast(void*)&exCreateImage;
            //TODO remove root
            import Mem = deltotum.core.utils.mem;
            Mem.addRootSafe(callback.context);
            Mem.addRootSafe(callback.func);

            auto mainMod = cast(jl_module_t*) jl_eval_string("Main");
            //TODO gc push?
            auto tf = jl_get_binding_wr(mainMod, jl_symbol("ExImage"), size_t.sizeof);
            jl_checked_assignment(tf, jl_box_voidpointer(cast(void*)(&callback)));

            jl_eval_string("
            struct ExCallback 
                   context::Ptr{Cvoid}
                   func::Ptr{Cvoid}
            end

            cbImagePtr = Base.unsafe_convert(Ptr{ExCallback}, ExImage)
            cbImage = Base.unsafe_load(cbImagePtr)

            function ext_image(buffer)
                buffLen = length(buffer.data)
                buffPtr = Base.unsafe_convert(Ptr{UInt8}, buffer.data)
                @ccall $(cbImage.func)(buffPtr::Ptr{UInt8}, buffLen::Csize_t, cbImage.context::Ptr{Cvoid})::Cvoid
            end
            ");
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

    static extern (C) void exCreateImage(void* buff, size_t buffLen, void* data)
    {
        if (auto scriptObject = cast(JuliaScriptTextPlugin) data)
        {
            if (scriptObject.onCreateImage)
            {
                import std.stdio : writeln;

                writeln("Run callback");
                scriptObject.onCreateImage(buff, buffLen);
            }

            return;
        }
        debug
        {
            import std.stdio;

            stderr.writeln("Invalid context received from script");
        }
    }

    //TODO jl_atexit_hook(0);

}
