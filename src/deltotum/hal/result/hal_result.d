module deltotum.hal.result.hal_result;

import core.attribute : mustuse;

/**
 * Authors: initkfs
 */
@mustuse struct HalResult
{
    immutable static codeSuccess = 0;

    int code = codeSuccess;
    string message;

    bool isError() const nothrow @nogc
    {
        return message.length > 0 || code != codeSuccess;
    }

    alias isError this;

    string toString() const nothrow
    {
        import std.conv : text;

        return text(message, " Code: ", code);
    }
}
