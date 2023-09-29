module deltotum.com.platforms.objects.com_ptr_manager;

/**
 * Authors: initkfs
 */
mixin template ComPtrManager(T)
{
    protected
    {
        T* ptr;
        bool isDestroyed;
    }

    abstract protected bool destroyPtr() @nogc nothrow;

    this() pure @safe
    {

    }

    this(T* ptr) pure @safe
    {
        import std.exception : enforce;

        enforce(ptr !is null, "Common native object pointer must not be null");
        this.ptr = ptr;
    }

    ~this()
    {
        if (ptr && !isDestroyed)
        {
            import std.stdio : stderr;

            stderr.writefln("Warning! Undestroyed common native object %s", typeof(this).stringof);
            destroy;
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

        enforce(newPtr !is null, "New common native object pointer must not be null");
        if (ptr)
        {
            destroyPtr;
        }
        ptr = newPtr;
        isDestroyed = false;
    }

    bool destroy() @nogc nothrow
    {
        if (ptr)
        {
            isDestroyed = destroyPtr;
            if (isDestroyed)
            {
                ptr = null;
            }
        }
        return isDestroyed;
    }
}
