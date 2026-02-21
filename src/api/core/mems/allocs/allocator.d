module api.core.mems.allocs.allocator;

/**
 * Authors: initkfs
 */

//Windows API: _aligned_malloc and _aligned_free
alias AllocFailHandler = void function() nothrow @trusted;
alias AllocFuncType = bool function(size_t size, scope ref ubyte[] ptr) nothrow @trusted;
alias AllocAlignFuncType = bool function(size_t size, scope ref ubyte[] ptr, ulong alignSize) nothrow @trusted;
alias ReallocFuncType = bool function(size_t newSize, scope ref ubyte[]) nothrow @trusted;
alias FreeFuncType = bool function(scope void* ptr) nothrow @trusted;

struct Allocator
{
    AllocFuncType allocFunPtr;
    AllocAlignFuncType allocAlignFunPtr;
    ReallocFuncType reallocFunPtr;
    FreeFuncType freeFunPtr;
    AllocFailHandler allocFailFunPtr;

    bool allocBytes(size_t size, scope ref ubyte[] ptr, size_t alignSize)
    {
        assert(allocFunPtr);
        assert(allocAlignFunPtr);
        return alignSize == 0 ? allocFunPtr(size, ptr) : allocAlignFunPtr(size, ptr, alignSize);
    }

    T[] array(T)(size_t capacity = 1, size_t alignSize = 0, bool isErrorOnFail = true, bool isCheckSizeOverflow = true)
    {
        if (capacity == 0)
        {
            return null;
        }

        const size = capacity * T.sizeof;

        if (isCheckSizeOverflow && (size / capacity) != T.sizeof)
        {
            if (isErrorOnFail)
            {
                enum message = "Allocation size overflow";
                version (D_Exceptions)
                {
                    throw new Exception(message);
                }
                else
                {
                    assert(false, message);
                    return null;
                }
            }
            else
            {
                return null;
            }
        }

        ubyte[] ptr;
        bool isAlloc = allocBytes(size, ptr, alignSize);
        if (!isAlloc)
        {
            if (isErrorOnFail)
            {
                enum message = "Allocation failed";
                version (D_Exceptions)
                {
                    throw new Exception(message);
                }
                else
                {
                    assert(false, message);
                    return null;
                }
            }
            else
            {
                while (allocFailFunPtr && !isAlloc)
                {
                    allocFailFunPtr();
                    isAlloc = allocBytes(size, ptr, alignSize);
                }

                if (!isAlloc || ptr.length == 0)
                {
                    return null;
                }
            }

        }

        return cast(T[]) ptr;
    }

    T[] realloc(T)(size_t newCapacity = 1, T[] ptr, bool isErrorOnFail = true, bool isCheckSizeOverflow = true)
    in (reallocFunPtr)
    {
        const newSize = newCapacity * T.sizeof;

        if (isCheckSizeOverflow && (newSize / newCapacity) != T.sizeof)
        {
            if (isErrorOnFail)
            {
                enum message = "Reallocation size overflow";
                version (D_Exceptions)
                {
                    throw new Exception(message);
                }
                else
                {
                    assert(false, message);
                    return null;
                }
            }
            else
            {
                return null;
            }
        }

        ubyte[] newPtr = cast(ubyte[]) ptr;
        if (!reallocFunPtr(newSize, newPtr))
        {
            if (isErrorOnFail)
            {
                enum message = "Reallocation failed";
                version (D_Exceptions)
                {
                    throw new Exception(message);
                }
                else
                {
                    assert(false, message);
                    return null;
                }
            }
            else
            {
                return null;
            }
        }

        return cast(T[]) newPtr;
    }

    bool free(void* ptr)
    in (freeFunPtr)
    {
        if (freeFunPtr(ptr))
        {
            return true;
        }

        return false;
    }
}
