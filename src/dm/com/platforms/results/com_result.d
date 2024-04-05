module dm.com.platforms.results.com_result;

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
        char[] message;
    }

    int codeSuccess;

    this(int code, const char[] message = null, int codeSuccess = defaultCodeSuccess) nothrow pure @safe
    {
        this.code = code;
        this.message = message;
        this.codeSuccess = codeSuccess;
    }

    static ComResult success() nothrow pure @safe
    {
        return ComResult(defaultCodeSuccess);
    }

    static ComResult error(const char[] message) nothrow pure @safe
    {
        return ComResult(defaultCodeError, message);
    }

    bool isError() const nothrow pure @safe
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
