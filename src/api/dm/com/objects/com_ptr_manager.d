module api.dm.com.objects.com_ptr_manager;

/**
 * Authors: initkfs
 */
mixin template ComPtrManager(T)
{
    import api.dm.com.com_result : ComResult;

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

            static if (__traits(compiles, this.id))
            {
                stderr.writefln("Warning! Undestroyed common native object %s, with id: %s", typeof(
                        this).stringof, id);
            }
            else
            {
                stderr.writefln("Warning! Undestroyed common native object %s", typeof(
                        this).stringof);
            }

            dispose;
        }
    }

    ComResult setWithDispose(T* newPtr) nothrow
    {
        if (!newPtr)
        {
            return ComResult.error("Error setting with dispose, new pointer is null");
        }
        if (ptr)
        {
            if (!disposePtr)
            {
                return ComResult.error(
                    "Error setting with dispose, previous pointer is not disposed");
            }
        }
        ptr = newPtr;
        return ComResult.success;
    }

    void setNull() nothrow
    {
        ptr = null;
    }

    final inout(T*) getObject() inout nothrow @safe
    out (p; p !is null)
    {
        return ptr;
    }

    final bool hasObject() nothrow pure @safe
    {
        return !isEmpty;
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
