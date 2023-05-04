module deltotum.com.platforms.results.com_result;

import core.attribute : mustuse;

/**
 * Authors: initkfs
 */
@mustuse struct ComResult
{
    enum defaultCodeSuccess = 0;
    enum defaultCodeError = -1;

    const
    {
        int code;
        //TODO free
        char[] message;
        int codeSuccess;
    }

    this(int code, const char[] message = "", int codeSuccess = defaultCodeSuccess) nothrow @nogc pure @safe
    {
        this.code = code;
        this.message = message;
        this.codeSuccess = codeSuccess;
    }

    static ComResult success() nothrow @nogc pure @safe
    {
        return ComResult(0);
    }

    static ComResult error(const char[] message) nothrow @nogc pure @safe
    {
        return ComResult(defaultCodeError, message);
    }

    bool isError() const nothrow @nogc pure @safe
    {
        return code != codeSuccess;
    }

    alias isError this;

    string toString() const nothrow pure @safe
    {
        import std.conv : text;

        return text("COM result with code ", code, ". ", "Message: ", message);
    }
}
