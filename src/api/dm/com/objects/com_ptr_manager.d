module api.dm.com.objects.com_ptr_manager;

/**
 * Authors: initkfs
 */
mixin template ComPtrManager(T)
{
    import api.dm.com.com_result : ComResult;

    protected
    {
        T* _ptr;
        bool _disposed;
    }

    abstract protected bool disposePtr() nothrow;

    this() pure @safe
    {

    }

    this(T* ptr) pure @safe
    {
        if (!ptr)
        {
            throw new Exception("Common native object pointer must not be null");
        }

        this._ptr = ptr;
    }

    ~this()
    {
        if (_ptr && !_disposed)
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

    ComResult updatePtr(T* newPtr) nothrow
    {
        if (!newPtr)
        {
            return ComResult.error("Error update pointer with dispose, new pointer is null");
        }
        if (_ptr)
        {
            if (!disposePtr)
            {
                return ComResult.error(
                    "Error update pointer with dispose, previous pointer is not disposed");
            }
        }

        _ptr = newPtr;
        _disposed = false;

        return ComResult.success;
    }

    void setNull() nothrow
    {
        _ptr = null;
    }

    inout(T*) ptr() inout nothrow @safe
    out (p; p !is null)
    {
        return _ptr;
    }

    void* rawPtr() nothrow => cast(void*) ptr;

    void ptr(T* newPtr) nothrow @safe
    {
        _ptr = newPtr;
    }

    bool hasPtr() nothrow pure @safe => _ptr !is null;
    bool isDisposed() nothrow pure @safe => _disposed;

    bool dispose() nothrow
    {
        if (_ptr)
        {
            _disposed = disposePtr;
            if (_disposed && _ptr)
            {
                _ptr = null;
            }
        }
        return _disposed;
    }
}
