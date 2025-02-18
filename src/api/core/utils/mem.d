module api.core.utils.mem;

import core.memory : GC;

/**
 * Authors: initkfs
 */

private
{
    enum noMoveGcAttr = GC.BlkAttr.NO_MOVE;
}

void addRange(void[] mem) @nogc nothrow
{
    GC.addRange(mem.ptr, mem.length);
}

void addRootSafe(void* ptr) nothrow
{
    GC.addRoot(ptr);
    GC.setAttr(ptr, noMoveGcAttr);
}

void removeRootSafe(void* ptr) nothrow
{
    GC.removeRoot(ptr);
    GC.clrAttr(ptr, noMoveGcAttr);
}

string formatBytes(size_t bytes, size_t bytesInUnit = 1000) pure @safe
{
    if (bytes == 0)
    {
        return "0B";
    }

    immutable postfix = ["B", "KB", "MB", "GB", "TB"];
    immutable lastPostfixIndex = postfix.length - 1;

    size_t postfixIndex = 0;
    double hBytes = bytes;
    for (postfixIndex = 0; (bytes / bytesInUnit) > 0 && postfixIndex < lastPostfixIndex;
        postfixIndex++, bytes /= bytesInUnit)
    {
        hBytes = bytes / (cast(double) bytesInUnit);
    }

    import std.format : format;

    return format("%s%s", hBytes, postfix[postfixIndex]);
    //return format("%.2f%s", hBytes, postfix[postfixIndex]);
}

unittest
{
    assert(formatBytes(0) == "0B");
    assert(formatBytes(1) == "1B");

    assert(formatBytes(1000) == "1KB");
    assert(formatBytes(2000) == "2KB");
    assert(formatBytes(100_000) == "100KB");
    assert(formatBytes(124_538) == "124.538KB");

    assert(formatBytes(1000_000) == "1MB");
}

long memBytes(bool isThrowOnInvalidIO = false) @trusted
{
    long result = -1;

    version (linux)
    {
        import std.stdio : File, KeepTerminator;
        import std.conv : to;
        import std.ascii : isDigit;
        import core.checkedint;

        static char[64] buffer = 0;
        size_t bufferSize;
        size_t fieldCount = 1;
        const size_t targetField = 2;

        try
        {
            auto statmFile = File("/proc/self/statm", "r");
            foreach (readBuff; statmFile.byLine(KeepTerminator.no, ' '))
            {
                if (fieldCount < targetField)
                {
                    fieldCount++;
                    continue;
                }

                if (readBuff.length == 0 || readBuff.length > buffer.length)
                {
                    return result;
                }

                bufferSize = readBuff.length;
                buffer[0 .. bufferSize] = readBuff[0 .. bufferSize];

                break;
            }

            auto digits = buffer[0 .. bufferSize];

            // foreach (digit; digits)
            // {
            //     if (!isDigit(digit))
            //     {
            //         return result;
            //     }
            // }

            import core.memory : pageSize;

            const byteInUnits = 1024;

            auto resultInKb = (digits.to!long) * (pageSize / byteInUnits);
            return resultInKb * 1024;
        }
        catch (Exception e)
        {
            if (isThrowOnInvalidIO)
            {
                throw e;
            }
            return result;
        }
    }
    else
    {
        return result;
    }
}
