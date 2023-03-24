module deltotum.platform.objects.platform_object_wrapper;

/**
 * Authors: initkfs
 */
mixin template PlatformObjectWrapper(T)
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
        import std.exception : enforce;

        enforce(ptr !is null, "Platform object pointer must not be null");
        this.ptr = ptr;
    }

    ~this()
    {
        if (ptr && !isDestroyed)
        {
            import std.stdio : stderr;

            stderr.writefln("Warning! Undestroyed platform object %s", typeof(this).stringof);
        }
    }

    final inout(T*) getObject() inout @nogc nothrow @safe
    out (p; p !is null)
    {
        return ptr;
    }

    final bool isEmpty() @nogc nothrow pure @safe
    {
        return ptr is null;
    }

    final void updateObject(T* newPtr)
    {
        import std.exception : enforce;

        enforce(newPtr !is null, "New platform object pointer must not be null");
        if (ptr)
        {
            destroyPtr;
        }
        ptr = newPtr;
        isDestroyed = false;
    }

    final bool destroy()
    {
        isDestroyed = ptr ? destroyPtr() : false;
        return isDestroyed;
    }
}
