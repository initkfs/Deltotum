module app.dm.com.platforms.objects.com_ptr_manager;

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

    abstract protected bool disposePtr() nothrow;

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

    final inout(T*) getObject() inout nothrow @safe
    out (p; p !is null)
    {
        return ptr;
    }

    final bool isEmpty() nothrow pure @safe
    {
        return ptr is null;
    }

    final bool isDisposed() nothrow pure @safe
    {
        return _disposed;
    }

    final void updateObject(T* newPtr) nothrow
    {
        assert(newPtr, "New common native object pointer must not be null");
        if (ptr)
        {
            disposePtr;
        }
        ptr = newPtr;
        _disposed = false;
    }

    bool dispose() nothrow
    {
        if (ptr)
        {
            _disposed = disposePtr;
            if (_disposed && ptr)
            {
                ptr = null;
            }
        }
        return _disposed;
    }
}
