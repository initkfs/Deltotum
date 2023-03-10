module deltotum.core.validations.exceptions.validation_fail_exception;
/**
 * Authors: initkfs
 */
class ValidationFailException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) @safe pure nothrow
    {
        super(msg, file, line, nextInChain);
    }

    this(string msg, Throwable nextInChain, string file = __FILE__, size_t line = __LINE__) @safe pure nothrow
    {
        super(msg, file, line, nextInChain);
    }
}
