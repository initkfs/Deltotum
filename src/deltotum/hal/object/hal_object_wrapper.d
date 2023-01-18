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

    this() pure @safe
    {

    }

    this(T* ptr) pure @safe
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

    final inout(T*) getObject() inout @nogc nothrow @safe
    {
        return ptr;
    }

    final bool isEmpty() @nogc nothrow pure @safe
    {
        return ptr is null;
    }

    final void updateObject(T* newPtr)
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
        isDestroyed = destroyPtr();
        return isDestroyed;
    }
}
