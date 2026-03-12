module api.dm.com.ptrs.com_ptr_manager;

import api.dm.com.objects.com_unique_object : ComUniqueObject;

/**
 * Authors: initkfs
 */
abstract class ComPtrManager(T) : ComUniqueObject
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

            stderr.writefln("Warning! Undestroyed common native object %s, with id: %s", typeof(
                    this).stringof, id);

            dispose;
        }
    }

    ComResult updatePtr(T* newPtr) nothrow
    {
        if (!newPtr)
        {
            import std.conv : text;

            return ComResult.error(
                text("Error update pointer with dispose, new pointer is null for ", T.stringof, " id: ", id));
        }

        if (_ptr)
        {
            if (!disposePtr)
            {
                import std.conv : text;

                return ComResult.error(
                    text("Error update pointer with dispose, previous pointer is not disposed for ", T
                        .stringof, " id:", id));
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
    {
        if (!_ptr)
        {
            throw new Error("Pointer is null");
        }
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

    ComNativePtr nativePtr() nothrow => ComNativePtr(_ptr);

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
