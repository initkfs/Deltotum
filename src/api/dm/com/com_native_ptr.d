module api.dm.com.com_native_ptr;

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
        assert(newPtr, "Pointer must not be null");
        _ptr = cast(void*) newPtr;
        _type = typeid(newPtr);
    }

    T castSafe(T)() inout nothrow
    {
        assert(_ptr);
        assert(_type);

        import std.conv : text;

        auto otherType = typeid(T);

        try
        {
            assert(_type == otherType, text("Expected cast type is ", otherType, ", but pointer type is ", _type));
        }
        catch (Exception e)
        {
            throw new Error("Exception in a safe cast attempt", e);
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
