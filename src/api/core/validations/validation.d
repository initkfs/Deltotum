module api.core.validations.validation;

import api.core.loggers.builtins.logger : Logger;
import api.core.validations.errors.err_status : ErrStatus;
import api.core.validations.validators.validator : Validator;

Validation newNullValidation() @safe
{
    return new Validation(new Logger, new ErrStatus);
}

/**
 * Authors: initkfs
 */
class Validation
{
    Logger _logger;

    ErrStatus errStatus;
    Validator[] validators;

    this(Logger logger, ErrStatus errStatus) pure @safe
    {
        assert(logger);
        assert(errStatus);
        this._logger = logger;
        this.errStatus = errStatus;
    }

    void validate()
    {
        foreach (v; validators)
        {
            v.validate;
            version (EnableTrace)
            {
                _logger.tracef("Run %s: %s", v.name, v.isValid);
            }
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
