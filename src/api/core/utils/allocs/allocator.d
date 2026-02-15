module api.core.utils.allocs.allocator;

/**
 * Authors: initkfs
 */

alias AllocFuncType = bool function(size_t size, scope ref ubyte[] ptr) nothrow @safe;
alias ReallocFuncType = bool function(size_t newSize, scope ref ubyte[]) nothrow @safe;
alias FreeFuncType = bool function(scope ubyte[] ptr) nothrow @safe;

mixin template MemFuncs()
{
    version (D_BetterC)
    {
        __gshared
        {
            AllocFuncType allocFunPtr;
            ReallocFuncType reallocFunPtr;
            FreeFuncType freeFunPtr;
        }
    }
    else
    {
        AllocFuncType allocFunPtr;
        ReallocFuncType reallocFunPtr;
        FreeFuncType freeFunPtr;
    }

    T[] array(T)(size_t capacity = 1, bool isErrorOnFail = true)
    in (allocFunPtr)
    {
        if (capacity == 0)
        {
            return null;
        }

        const size = capacity * T.sizeof;

        if ((size / capacity) != T.sizeof)
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
                }
            }
            else
            {
                return null;
            }
        }

        ubyte[] ptr;
        if (!allocFunPtr(size, ptr) && isErrorOnFail)
        {
            enum message = "Allocation failed";
            version (D_Exceptions)
            {
                throw new Exception(message);
            }
            else
            {
                assert(false, message);
            }
        }

        return cast(T[]) ptr;
    }

    T[] realloc(T)(size_t newCapacity = 1, T[] ptr, bool isErrorOnFail = true)
    in (reallocFunPtr)
    {
        const newSize = newCapacity * T.sizeof;

        if ((newSize / newCapacity) != T.sizeof)
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
                }
            }
            else
            {
                return null;
            }
        }

        ubyte[] newPtr = cast(ubyte[]) ptr;
        if (!reallocFunPtr(newSize, newPtr) && isErrorOnFail)
        {
            enum message = "Reallocation failed";
            version (D_Exceptions)
            {
                throw new Exception(message);
            }
            else
            {
                assert(false, message);
            }
        }

        return cast(T[]) newPtr;
    }

    bool free(void[] ptr)
    in (freeFunPtr)
    {
        if (freeFunPtr(cast(ubyte[]) ptr))
        {
            return true;
        }

        return false;
    }
}

version (D_BetterC)
{
    mixin MemFuncs;
}
else
{
    abstract class Allocator
    {
        mixin MemFuncs;

        bool canAlloc() const nothrow pure @safe => true;
    }
}
