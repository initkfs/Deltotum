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
        enforce(ptr !is null, "SDL object pointer must not be null");
        this.ptr = ptr;
    }

    T* getSdlObject() @nogc nothrow @safe
    {
        return ptr;
    }

    void updateObject(T* newPtr)
    {
        enforce(newPtr !is null, "New SDL object pointer must not be null");
        if (ptr)
        {
            destroy;
        }
        ptr = newPtr;
    }
}
