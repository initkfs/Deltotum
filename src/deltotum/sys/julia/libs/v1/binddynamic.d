module deltotum.sys.julia.libs.v1.binddynamic;

/**
 * Authors: initkfs
 */
version (JuliaV1)  : import deltotum.sys.julia.libs.v1.types;
import deltotum.sys.base.sys_lib : SysLib;

import core.stdc.stdint;

extern (C) @nogc nothrow
{
    alias j_jl_gc_enable = int function(int);
    alias j_JL_GC_PUSH1 = void function(void*);
    alias j_jl_checked_assignment = void function(jl_binding_t* b, jl_value_t* rhs);
    alias j_jl_get_binding_wr = jl_binding_t* function(jl_module_t* m, jl_sym_t* var, int alloc);

    alias j_jl_init = void function();
    alias j_jl_eval_string = jl_value_t* function(const char*);
    alias j_jl_atexit_hook = void function(int);

    alias j_jl_set_global = void function(jl_module_t* m, jl_sym_t* var, jl_value_t* val);

    alias j_jl_box_bool = jl_value_t* function(uint8_t);
    alias j_jl_box_uint64 = jl_value_t* function(uint64_t);
    alias j_jl_box_voidpointer = jl_value_t* function(void*);

    alias j_jl_unbox_float64 = double function(jl_value_t*);
    alias j_jl_unbox_int32 = int32_t function(jl_value_t*);
    alias j_jl_unbox_int64 = int64_t function(jl_value_t*);
    alias j_jl_unbox_bool = bool function(jl_value_t*);

    alias j_jl_typeof_str = const(char*) function(jl_value_t*);
    alias j_jl_string_ptr = const(char*) function(jl_value_t*);
    alias j_jl_exit = void function(int);
    alias j_jl_exception_occurred = jl_value_t* function();
    alias j_jl_current_exception = jl_value_t* function();
    alias j_jl_exception_clear = void function();
    alias j_jl_base_module = jl_module_t* function();
    alias j_jl_core_module = jl_module_t* function();
    alias j_jl_get_global = jl_value_t* function(jl_module_t* m, jl_sym_t* var);
    alias j_jl_symbol_name = void* function(jl_sym_t* s);
    alias j_jl_symbol = jl_sym_t* function(const char* str);
    alias j_jl_stderr_obj = jl_value_t* function();

    alias j_jl_call2 = jl_value_t* function(jl_function_t* f, jl_value_t* a, jl_value_t* b);
    alias j_jl_call1 = jl_value_t* function(jl_function_t* f, jl_value_t* a);

    alias j_jl_printf = int function(uv_stream_s* s, const char* format, ...);
    alias j_jl_stderr_stream = uv_stream_s* function();
}

__gshared
{
    j_JL_GC_PUSH1 JL_GC_PUSH1;
    j_jl_checked_assignment jl_checked_assignment;
    j_jl_get_binding_wr jl_get_binding_wr;
    j_jl_gc_enable jl_gc_enable;

    j_jl_init jl_init;
    j_jl_eval_string jl_eval_string;
    j_jl_atexit_hook jl_atexit_hook;

    j_jl_set_global jl_set_global;

    j_jl_box_bool jl_box_bool;
    j_jl_box_uint64 jl_box_uint64;
    j_jl_box_voidpointer jl_box_voidpointer;

    j_jl_unbox_float64 jl_unbox_float64;
    j_jl_unbox_int32 jl_unbox_int32;
    j_jl_unbox_int64 jl_unbox_int64;
    j_jl_unbox_bool jl_unbox_bool;

    j_jl_typeof_str jl_typeof_str;
    j_jl_exit jl_exit;

    j_jl_string_ptr jl_string_ptr;

    j_jl_current_exception jl_current_exception;
    j_jl_exception_occurred jl_exception_occurred;
    j_jl_exception_clear jl_exception_clear;

    j_jl_base_module jl_base_module;
    j_jl_get_global jl_get_global;
    j_jl_core_module jl_core_module;
    j_jl_symbol jl_symbol;
    j_jl_call1 jl_call1;
    j_jl_call2 jl_call2;

    j_jl_stderr_obj jl_stderr_obj;
    j_jl_printf jl_printf;
    j_jl_stderr_stream jl_stderr_stream;

}

jl_function_t* jl_get_function(jl_module_t* m, const char* name)
{
    return cast(jl_function_t*) jl_get_global(m, jl_symbol(name));
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
        bind(cast(void**)&jl_gc_enable, "jl_gc_enable");
        bind(cast(void**)&jl_get_binding_wr, "jl_get_binding_wr");
        bind(cast(void**)&jl_checked_assignment, "jl_checked_assignment");

        bind(cast(void**)&jl_init, "jl_init");
        bind(cast(void**)&jl_eval_string, "jl_eval_string");
        bind(cast(void**)&jl_atexit_hook, "jl_atexit_hook");

        bind(cast(void**)&jl_set_global, "jl_set_global");

        bind(cast(void**)&jl_box_bool, "jl_box_bool");
        bind(cast(void**)&jl_box_uint64, "jl_box_uint64");
        bind(cast(void**)&jl_box_voidpointer, "jl_box_voidpointer");
        bind(cast(void**)&jl_unbox_float64, "jl_unbox_float64");
        bind(cast(void**)&jl_unbox_int32, "jl_unbox_int32");
        bind(cast(void**)&jl_unbox_int64, "jl_unbox_int64");
        bind(cast(void**)&jl_unbox_bool, "jl_unbox_bool");
        bind(cast(void**)&jl_typeof_str, "jl_typeof_str");
        bind(cast(void**)&jl_string_ptr, "jl_string_ptr");
        bind(cast(void**)&jl_exception_occurred, "jl_exception_occurred");
        bind(cast(void**)&jl_current_exception, "jl_current_exception");
        bind(cast(void**)&jl_exception_clear, "jl_exception_clear");
        bind(cast(void**)&jl_exit, "jl_exit");

        bind(cast(void**)&jl_base_module, "jl_base_module");
        bind(cast(void**)&jl_core_module, "jl_core_module");
        bind(cast(void**)&jl_get_global, "jl_get_global");
        bind(cast(void**)&jl_symbol, "jl_symbol");
        bind(cast(void**)&jl_call1, "jl_call1");
        bind(cast(void**)&jl_call2, "jl_call2");

        bind(cast(void**)&jl_stderr_obj, "jl_stderr_obj");
        bind(cast(void**)&jl_stderr_stream, "jl_stderr_stream");
        bind(cast(void**)&jl_printf, "jl_printf");
    }

    override protected int needVersion()
    {
        return 1;
    }

}
