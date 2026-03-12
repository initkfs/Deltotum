module api.dm.com.ptrs.com_native_ptr;

/**
 * Authors: initkfs
 */
struct ComNativePtr
{
    private
    {
        void* _ptr;
        TypeInfo _type;
    }

    this(T)(T* newPtr) pure nothrow
    {
        if (newPtr)
        {
            _ptr = cast(void*) newPtr;
            _type = typeid(newPtr);
        }
    }

    T castSafe(T)() inout nothrow
    {
        if (!_ptr)
        {
            throw new Error("Pointer is null");
        }

        if (!_type)
        {
            throw new Error("Pointer type is null");
        }

        auto otherType = typeid(T);

        bool isForType;
        try
        {
            isForType = _type == otherType;
        }
        catch (Exception e)
        {
            throw new Error(e.toString);
        }

        if (!isForType)
        {
            import std.conv : text;

            throw new Error(text("Expected cast type is ", otherType, ", but pointer type is ", _type));
        }

        return cast(T) _ptr;
    }

    inout(void*) ptr() inout nothrow
    {
        assert(_ptr, "Pointer is null");
        return _ptr;
    }

    inout(TypeInfo) type() inout nothrow
    {
        assert(_type);
        return _type;
    }
}
