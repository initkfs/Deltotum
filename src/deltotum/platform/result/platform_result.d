module deltotum.platform.result.platform_result;

import core.attribute : mustuse;

/**
 * Authors: initkfs
 */
@mustuse struct PlatformResult
{
    enum defaultCodeSuccess = 0;
    enum defaultCodeError = -1;

    immutable
    {
        int code;
        string message;
        int codeSuccess;
    }

    this(int code, string message = "", int codeSuccess = defaultCodeSuccess) inout nothrow @nogc pure @safe
    {
        this.code = code;
        this.message = message;
        this.codeSuccess = codeSuccess;
    }

    static PlatformResult success() nothrow @nogc pure @safe
    {
        return PlatformResult(0);
    }

    static PlatformResult error(string message) nothrow @nogc pure @safe
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

        const string stringMessage = message.length > 0 ? message : "\"\"";
        return text("Result code: ", code, ". ", "Message: ", stringMessage);
    }
}
