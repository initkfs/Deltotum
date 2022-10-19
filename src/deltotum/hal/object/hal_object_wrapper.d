module deltotum.hal.object.hal_object_wrapper;

import deltotum.hal.object.hal_object : HalObject;

import std.exception : enforce;

/**
 * Authors: initkfs
 */
mixin template HalObjectWrapper(T)
{
    protected
    {
        T* ptr;
        bool isDestroyed;
    }

    abstract protected bool destroyPtr();

    this()
    {

    }

    this(T* ptr)
    {
        enforce(ptr !is null, "Object pointer must not be null");
        this.ptr = ptr;
    }

    ~this()
    {
        if (ptr && !isDestroyed)
        {
            import std.stdio : stderr;
            stderr.writefln("Warning! Undestroyed HAL object %s", typeof(this).stringof);
        }
    }

    inout(T*) getSdlObject() inout @nogc nothrow @safe
    {
        return ptr;
    }

    bool isEmpty() @nogc nothrow pure @safe {
        return ptr is null;
    }

    void updateObject(T* newPtr)
    {
        enforce(newPtr !is null, "New object pointer must not be null");
        if (ptr)
        {
            destroyPtr;
        }
        ptr = newPtr;
        isDestroyed = false;
    }

    final bool destroy()
    {
        isDestroyed = destroyPtr;
        return isDestroyed;
    }
}
