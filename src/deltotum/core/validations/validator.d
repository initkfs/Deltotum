module deltotum.core.validations.validator;

import deltotum.core.validations.exceptions.validation_fail_exception : ValidationFailException;

/**
 * Authors: initkfs
 */
abstract class Validator
{

    protected
    {
        string mainFailMessage;
        string[] failMessages;

        Exception[] exceptions;
        string[] errorMessages;

        bool success;
    }

    abstract {
        void validate();
    }

    void validateForce(const bool isValid)
    {
        validate();
        setSuccess(isValid);
    }

    bool isValid() @safe pure const nothrow
    {
        return !isError && isSuccess;
    }

    protected void setValid() @safe pure nothrow
    {
        setSuccess(true);
    }

    protected void setValidWithoutErrors() @safe pure nothrow
    {
        resetErrors;
        setValid;
    }

    protected void setInvalid(const string[] failMessages...) @safe pure
    {
        setSuccess(false);
        if (failMessages.length > 0)
        {
            addFailMessages(failMessages);
        }
    }

    protected void setInvalidWithError(const string[] errors...) @safe pure
    {
        setInvalid;
        if (errors.length > 0)
        {
            addErrorMessages(errors);
        }
    }

    protected void setInvalidWithException(Exception[] exceptions...) @safe pure
    {
        setInvalid;
        addExceptions(exceptions);
    }

    protected void setInvalidWithError(const string error, Exception e) @safe pure
    {
        setInvalidWithException(e);
        setInvalidWithError(error);
    }

    protected void resetErrors() @safe pure nothrow
    {
        this.exceptions = [];
        this.errorMessages = [];
    }

    bool isError() @safe pure nothrow const
    {
        return this.exceptions.length > 0 || this.errorMessages.length > 0;
    }

    void throwExceptionIfInvalid()
    {
        if (isValid)
        {
            return;
        }

        import std.array : appender;

        auto resultMessage = appender!string;

        resultMessage.put(this.classinfo.name);
        resultMessage.put(". ");

        const failMessage = getFailMessagesAsString();
        if (failMessage.length == 0)
        {
            resultMessage.put(
                "Validator's fail message is empty. Perhaps validation has not been run.");
            resultMessage.put(" ");
        }
        else
        {
            const allMessages = getAllMessagesAsString;
            if (allMessages.length > 0)
            {
                resultMessage.put(allMessages);
            }

        }

        throw new ValidationFailException(resultMessage.data);
    }

    private string formatAsString(const string[] stringArray) @safe pure nothrow const
    {
        if (stringArray.length == 0)
        {
            return "";
        }
        import std.array : join;

        const resultString = stringArray.join(";");
        return resultString;
    }

    private string getExceptionsAsString()
    {
        if (this.exceptions.length == 0)
        {
            return "";
        }

        import std.algorithm.iteration : map;
        import std.array : array;

        string[] exStrings = this.exceptions.map!(ex => ex.toString).array;
        const exString = formatAsString(exStrings);
        return exString;
    }

    string getFailMessagesAsString() @safe pure const
    {
        const string failMessagesString = formatAsString(getFailMessages);
        return failMessagesString;
    }

    string getErrorMessagesAsString() @safe pure const
    {
        const string errorsString = formatAsString(getErrorMessages);
        return errorsString;
    }

    string getAllMessagesAsString()
    {
        import std.array : appender;

        auto sb = appender!string;

        const partSeparator = ". ";

        sb.put(getMainFailMessage);
        sb.put(partSeparator);

        if (this.failMessages.length > 0)
        {
            sb.put("Fail: ");
            sb.put(getFailMessagesAsString);
            sb.put(partSeparator);
        }

        if (this.errorMessages.length > 0)
        {
            sb.put("Errors: ");
            sb.put(getErrorMessagesAsString);
            sb.put(partSeparator);
        }

        if (this.exceptions.length > 0)
        {
            sb.put("Exceptions: ");
            sb.put(getExceptionsAsString);
            sb.put(partSeparator);
        }
        return sb.data;
    }

    override string toString()
    {
        import std.format : format;

        const toStringMessage = format("%s; valid: %s; %s", this.classinfo.name, isValid, getAllMessagesAsString);
        return toStringMessage;
    }

    protected void addExceptions(Exception[] exceptions...) @safe pure
    {
        import std.exception: enforce;

        enforce(exceptions.length > 0, "Exceptions must not be empty");
        this.exceptions ~= exceptions;
    }

    Exception[] getExceptions() @safe pure nothrow
    {
        return this.exceptions;
    }

    bool isSuccess() @safe pure nothrow const
    {
        return this.success;
    }

    private void setSuccess(const bool value) @safe pure nothrow
    {
        this.success = value;
    }

    string getMainFailMessage() @safe pure nothrow const
    {
        return this.mainFailMessage;
    }

    void setMainFailMessage(const string message) @safe pure nothrow
    {
        this.mainFailMessage = message;
    }

    protected void addFailMessages(const string[] messages...) @safe pure
    {
        import std.exception: enforce;
        enforce(messages.length > 0, "Fail messages must not be empty");
        this.failMessages ~= messages;
    }

    protected void addErrorMessages(const string[] messages...) @safe pure
    {
        import std.exception: enforce;
        enforce(messages.length > 0, "Error messages must not be empty");
        this.errorMessages ~= messages;
    }

    const(string[]) getFailMessages() @safe pure nothrow const
    {
        import std.conv : to;

        auto failsCopy = to!(const(string[]))(failMessages);
        return failsCopy;
    }

    const(string[]) getErrorMessages() @safe pure nothrow const
    {
        import std.conv : to;

        auto errorsCopy = to!(const(string[]))(errorMessages);
        return errorsCopy;
    }

    unittest
    {

        const string failMessage = "Main fail message";

        class TestValidator : Validator
        {

            this()
            {
                setMainFailMessage(failMessage);
            }

            override void validate()
            {
                setValidWithoutErrors;
            }
        }

        auto validator = new TestValidator();
        assert(validator.getMainFailMessage == failMessage);
        validator.validate;
        assert(!validator.isError);
        assert(validator.isSuccess);
        assert(validator.isValid);
        assert(validator.getErrorMessages.length == 0);
        assert(validator.getExceptions.length == 0);
        assert(validator.getFailMessages.length == 0);

        const failMessage1 = "Fail message1";
        const failMessage2 = "Fail message2";

        const errorMessage1 = "Error message1";
        const errorMessage2 = "Error message2";

        Exception exception1 = new Exception("Exception message");

        class TestFailValidator : TestValidator
        {

            override void validate()
            {
                setInvalid(failMessage1);
                setInvalid(failMessage2);

                setInvalidWithError(errorMessage1);
                setInvalidWithError(errorMessage2);

                setInvalidWithException(exception1);
            }
        }

        auto failValidator = new TestFailValidator();
        assert(failValidator.getMainFailMessage == failMessage);
        failValidator.validate;
        assert(!failValidator.isSuccess);
        assert(failValidator.isError);
        assert(!failValidator.isValid);

        assert(failValidator.getFailMessages == [failMessage1, failMessage2]);
        assert(failValidator.getErrorMessages == [errorMessage1, errorMessage2]);
        assert(failValidator.getExceptions == [exception1]);

        failValidator.resetErrors;
        assert(failValidator.getErrorMessages.length == 0);
        assert(failValidator.getExceptions.length == 0);

    }

}
