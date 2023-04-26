module deltotum.com.results.platform_result;

import core.attribute : mustuse;

/**
 * Authors: initkfs
 */
@mustuse struct PlatformResult
{
    enum defaultCodeSuccess = 0;
    enum defaultCodeError = -1;

    const
    {
        int code;
        char[] message;
        int codeSuccess;
    }

    this(int code, const char[] message = "", int codeSuccess = defaultCodeSuccess) nothrow @nogc pure @safe
    {
        this.code = code;
        this.message = message;
        this.codeSuccess = codeSuccess;
    }

    static PlatformResult success() nothrow @nogc pure @safe
    {
        return PlatformResult(0);
    }

    static PlatformResult error(const char[] message) nothrow @nogc pure @safe
    {
        return PlatformResult(defaultCodeError, message);
    }

    bool isError() const nothrow @nogc pure @safe
    {
        return code != codeSuccess;
    }

    alias isError this;

    string toString() const nothrow pure @safe
    {
        import std.conv : text;

        return text("Platform result with code ", code, ". ", "Message: ", message);
    }
}
