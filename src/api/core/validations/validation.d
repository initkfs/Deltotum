module api.core.validations.validation;

import api.core.validations.errors.err_status : ErrStatus;
import api.core.validations.validators.validator : Validator;

Validation newNullValidation() @safe
{
    return new Validation(new ErrStatus);
}

/**
 * Authors: initkfs
 */
class Validation
{
    ErrStatus errStatus;
    Validator[] validators;

    this(ErrStatus errStatus) pure @safe
    {
        assert(errStatus);
        this.errStatus = errStatus;
    }

    void validate()
    {
        foreach (v; validators)
        {
            v.validate;
        }
    }

    bool isValid()
    {
        foreach (v; validators)
        {
            if (!v.isValid)
            {
                return false;
            }
        }

        return true;
    }

    string allMessages()
    {
        import std.array : appender;

        auto result = appender!string;

        foreach (v; validators)
        {
            if ((!v.isError) && (!v.isFail))
            {
                continue;
            }

            result.put(v.allMessages);
        }

        return result.data;
    }

}
