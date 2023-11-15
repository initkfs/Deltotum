module dm.com.platforms.objects.com_ptr_manager;

/**
 * Authors: initkfs
 */
mixin template ComPtrManager(T)
{
    protected
    {
        T* ptr;
        bool _disposed;
    }

    abstract protected bool disposePtr() @nogc nothrow;

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
        if (ptr && !_disposed)
        {
            import std.stdio : stderr;

            stderr.writefln("Warning! Undestroyed common native object %s", typeof(this).stringof);
            dispose;
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

    final bool isDisposed() @nogc nothrow pure @safe
    {
        return _disposed;
    }

    final void updateObject(T* newPtr)
    {
        import std.exception : enforce;

        enforce(newPtr !is null, "New common native object pointer must not be null");
        if (ptr)
        {
            disposePtr;
        }
        ptr = newPtr;
        _disposed = false;
    }

    bool dispose() @nogc nothrow
    {
        if (ptr)
        {
            _disposed = disposePtr;
            if (_disposed)
            {
                ptr = null;
            }
        }
        return _disposed;
    }
}
