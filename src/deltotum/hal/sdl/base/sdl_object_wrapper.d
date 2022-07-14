module deltotum.hal.sdl.base.sdl_object_wrapper;

import deltotum.hal.sdl.base.sdl_object : SdlObject;

import std.exception : enforce;

/**
 * Authors: initkfs
 */
abstract class SdlObjectWrapper(T) : SdlObject
{
    protected
    {
        T* ptr;
    }

    abstract void destroy();

    this()
    {

    }

    this(T* ptr)
    {
        enforce(ptr !is null, "Pointer must not be null");
        this.ptr = ptr;
    }

    T* getStruct() @nogc nothrow @safe
    {
        return ptr;
    }

    void updateStruct(T* newPtr)
    {
        if (ptr)
        {
            destroy;
        }
        ptr = newPtr;
    }
}
