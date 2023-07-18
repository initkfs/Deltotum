module deltotum.sys.julia.libs.v1.binddynamic;

/**
 * Authors: initkfs
 */
version (JuliaV1)  : import deltotum.sys.julia.libs.v1.types;
import deltotum.sys.base.sys_lib : SysLib;

import core.stdc.stdint;

extern (C) @nogc nothrow
{
    alias j_jl_init = void function();
    alias j_jl_eval_string = jl_value_t* function(const char*);
    alias j_jl_atexit_hook = void function(int);
    
    alias j_jl_unbox_float64 = double function(jl_value_t*);
    alias j_jl_unbox_int32 = int32_t function(jl_value_t*);
    alias j_jl_unbox_int64 = int64_t function(jl_value_t*);
    alias j_jl_unbox_bool = bool function(jl_value_t*);
    
    alias j_jl_typeof_str = const(char*) function(jl_value_t*);
    alias j_jl_string_ptr = const(char*) function(jl_value_t*);
    alias j_jl_exit = void function(int);
    alias j_jl_exception_occurred = jl_value_t* function();
    alias j_jl_exception_clear = void function();
}

__gshared
{
    j_jl_init jl_init;
    j_jl_eval_string jl_eval_string;
    j_jl_atexit_hook jl_atexit_hook;
    
    j_jl_unbox_float64 jl_unbox_float64;
    j_jl_unbox_int32 jl_unbox_int32;
    j_jl_unbox_int64 jl_unbox_int64;
    j_jl_unbox_bool jl_unbox_bool;
    
    j_jl_typeof_str jl_typeof_str;
    j_jl_exit jl_exit;

    j_jl_string_ptr jl_string_ptr;

    j_jl_exception_occurred jl_exception_occurred;
    j_jl_exception_clear jl_exception_clear;
}

class JuliaLib : SysLib
{
    version (Windows)
    {
        const(char)[][1] paths = ["libjulia.dll"];
    }
    else version (OSX)
    {
        const(char)[][1] paths = ["libjulia.dylib"];
    }
    else version (Posix)
    {
        const(char)[][1] paths = ["libjulia.so"];
    }
    else
    {
        const(char)[0][0] paths;
    }

    override const(char[][]) libPaths()
    {
        return paths;
    }

    override void bindSymbols()
    {
        bind(cast(void**)&jl_init, "jl_init");
        bind(cast(void**)&jl_eval_string, "jl_eval_string");
        bind(cast(void**)&jl_atexit_hook, "jl_atexit_hook");
        bind(cast(void**)&jl_unbox_float64, "jl_unbox_float64");
        bind(cast(void**)&jl_unbox_int32, "jl_unbox_int32");
        bind(cast(void**)&jl_unbox_int64, "jl_unbox_int64");
        bind(cast(void**)&jl_unbox_bool, "jl_unbox_bool");
        bind(cast(void**)&jl_typeof_str, "jl_typeof_str");
        bind(cast(void**)&jl_string_ptr, "jl_string_ptr");
        bind(cast(void**)&jl_exception_occurred, "jl_exception_occurred");
        bind(cast(void**)&jl_exception_clear, "jl_exception_clear");
        bind(cast(void**)&jl_exit, "jl_exit");
    }

    override protected int needVersion()
    {
        return 1;
    }

}
