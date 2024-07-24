module app.dm.com.platforms.results.com_result;

import core.attribute : mustuse;

/**
 * Authors: initkfs
 */
@mustuse struct ComResult
{
    enum defaultCodeSuccess = 0;
    enum defaultCodeError = -1;

    int code;
    string message;
    bool isError;

    this(int code, string message = null, bool isError = false) inout @nogc nothrow pure @safe
    {
        this.code = code;
        this.message = message;
        this.isError = isError;
    }

    static ComResult success(int code = defaultCodeSuccess) @nogc nothrow pure @safe
    {
        return ComResult(code, null, false);
    }

    static ComResult error(int code = defaultCodeError) @nogc nothrow pure @safe
    {
        return ComResult(code, null, true);
    }

    static ComResult error(string message) @nogc nothrow pure @safe
    {
        return ComResult(defaultCodeError, message, true);
    }

    static ComResult error(int code, string[] messages...) nothrow pure @safe
    {
        import std.conv : text;

        try
        {
            return ComResult(code, text(messages), true);
        }
        catch (Exception e)
        {
            assert(0, e.msg);
        }
    }

    bool convToBool() const @nogc nothrow pure @safe
    {
        return isError;
    }

    alias convToBool this;

    string toString() const nothrow pure @safe
    {
        import std.conv : text;

        return text("COM result, error: ", convToBool, ", code: ", code, ", ", "messages: ", message);
    }
}

unittest
{
    import std.conv : to;

    const codeSuccess = ComResult.defaultCodeSuccess;
    const codeError = ComResult.defaultCodeError;

    immutable res1 = immutable ComResult(codeSuccess);
    assert(!res1);
    assert(!res1.isError);
    assert(res1.code == codeSuccess, res1.code.to!string);

    immutable res2 = ComResult(codeSuccess, "message");
    assert(!res2.isError);
    assert(res2.code == codeSuccess, res2.code.to!string);
    assert(res2.message == "message", res2.message);

    immutable resSucc1 = ComResult.success;
    assert(!resSucc1.isError);
    assert(resSucc1.code == codeSuccess, resSucc1.code.to!string);
    assert(resSucc1.message.length == 0, resSucc1.message);

    immutable resFail1 = ComResult.error;
    assert(resFail1.isError);
    assert(resFail1.code == codeError, resFail1.code.to!string);
    assert(resFail1.message.length == 0, resFail1.message);

    immutable resFail2 = ComResult.error(codeSuccess, "message1", "message2");
    assert(resFail2.isError);
    assert(resFail2.code == codeSuccess, resFail2.code.to!string);
    assert(resFail2.message == "[\"message1\", \"message2\"]", resFail2.message);
}
