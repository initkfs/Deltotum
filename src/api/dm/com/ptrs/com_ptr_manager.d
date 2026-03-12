module api.dm.com.ptrs.com_ptr_manager;

/**
 * Authors: initkfs
 */
abstract class ComPtrManager(T)
{
    import api.dm.com.com_result : ComResult;
    import api.dm.com.ptrs.com_native_ptr : ComNativePtr;

    private
    {
        T* _ptr;
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
        if (_ptr)
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
            return ComResult.error(
                "Error update pointer with dispose, new pointer is null for " ~ T.stringof);
        }

        if (_ptr)
        {
            if (!disposePtr)
            {
                return ComResult.error(
                    "Error update pointer with dispose, previous pointer is not disposed for " ~ T
                        .stringof);
            }
        }

        _ptr = newPtr;
        return ComResult.success;
    }

    void setNullPtr() nothrow
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
        if (_ptr)
        {
            throw new Error("Pointer not disposed: " ~ T.stringof);
        }

        _ptr = newPtr;
    }

    ComResult nativePtr(out ComNativePtr nptr) nothrow
    {
        if (!_ptr)
        {
            return ComResult.error("Pointer is null " ~ T.stringof);
        }

        nptr = ComNativePtr(_ptr);
        return ComResult.success;
    }

    bool hasPtr() nothrow pure @safe => _ptr !is null;
    bool isDisposed() nothrow pure @safe => !hasPtr;

    bool dispose() nothrow
    {
        bool isDispose = disposePtr;
        if (isDispose && _ptr)
        {
            _ptr = null;
        }

        return isDispose;
    }
}
