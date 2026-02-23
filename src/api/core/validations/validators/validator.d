module api.core.validations.validators.validator;

/**
 * Authors: initkfs
 */
abstract class Validator
{
    protected
    {
        bool _valid;

        string[] _fails;
        Throwable[] _errors;
    }

    bool isAutoFailOnErrors = true;

    abstract
    {
        void validate();
    }

    void validate(bool valid)
    {
        validate;
        isValid = valid;
    }

    bool isValid() const nothrow pure @safe => _valid;
    void isValid(bool newValue)
    {
        _valid = newValue;
    }

    bool isError() const nothrow pure @safe => _errors.length > 0;
    bool isFail() const nothrow pure @safe => _fails.length > 0;

    protected void setValid()
    {
        isValid = true;
    }

    void setInvalid()
    {
        isValid = false;
    }

    protected void setValidReset()
    {
        setValid;
        reset;
    }

    protected void setInvalid(string failMessage = null, Throwable error = null)
    {
        setInvalid;

        if (failMessage.length > 0)
        {
            addFail(failMessage);
        }

        if (error)
        {
            addError(error);
        }
    }

    protected void setInvalid(string[] failMessages = null, Throwable[] errors = null)
    {
        setInvalid;

        if (failMessages.length > 0)
        {
            addFail(failMessages);
        }

        if (errors.length > 0)
        {
            addError(errors);
        }
    }

    void addFail(string message)
    {
        if (message.length == 0)
        {
            return;
        }

        _fails ~= message;
        if (isAutoFailOnErrors && isValid)
        {
            setInvalid;
        }
    }

    void addFail(string[] messages)
    {
        foreach (m; messages)
        {
            addFail(m);
        }
    }

    void addError(Throwable error)
    {
        if (!error)
        {
            return;
        }

        _errors ~= error;
        if (isAutoFailOnErrors && isValid)
        {
            setInvalid;
        }
    }

    void addError(Throwable[] errors)
    {
        foreach (e; errors)
        {
            addError(e);
        }
    }

    protected void reset()
    {
        resetFails;
        resetErrors;
        setInvalid;
    }

    protected void resetFails()
    {
        _fails = null;
    }

    protected void resetErrors()
    {
        _errors = null;
    }

    string allMessages()
    {
        if (isValid && (!isError) && (!isFail))
        {
            return null;
        }

        import std.array : appender;

        auto resultMessage = appender!string;
        resultMessage.put(this.classinfo.name);

        const failMessage = failsToString;
        if (failMessage.length > 0)
        {
            resultMessage.put(". Fails: ");
            resultMessage.put(failMessage);
        }

        const errorMessage = errorsToString;
        if (errorMessage.length > 0)
        {
            resultMessage.put(". Errors: ");
            resultMessage.put(errorMessage);
        }

        return resultMessage.data;
    }

    private string formatAsString(const string[] stringArray, char joinSep = ';') @safe pure const
    {
        if (stringArray.length == 0)
        {
            return "";
        }
        import std.array : join;

        const resultString = stringArray.join(joinSep);
        return resultString;
    }

    string errorsToString()
    {
        if (_errors.length == 0)
        {
            return null;
        }

        import std.algorithm.iteration : map;
        import std.array : array;

        string[] exStrings = _errors.map!(ex => ex.toString).array;
        return formatAsString(exStrings);
    }

    string failsToString() @safe pure const
    {
        if (_fails.length == 0)
        {
            return null;
        }

        return formatAsString(_fails);
    }

    override string toString()
    {
        import std.format : format;

        const toStringMessage = format("%s; valid %s: %s", this.classinfo.name, isValid, allMessages);
        return toStringMessage;
    }

    inout(Throwable[]) errors() inout pure nothrow @safe => _errors;
    inout(string[]) fails() inout pure nothrow @safe => _fails;
}

// unittest
// {
//     class CustomValidator : Validator
//     {

//         override void validate()
//         {
//             setInvalid;
//             addFail(["Fail message 1", "Fail message 2"]);
//             addError([new Exception("Exception 1"), new Exception("Exception 2")]);
//         }
//     }
// }
