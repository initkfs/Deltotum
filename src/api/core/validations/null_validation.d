module api.core.validations.null_validation;

import api.core.validations.validation : Validation;
import api.core.loggers.builtins.logger : Logger;
import api.core.validations.errors.err_status : ErrStatus;

/**
 * Authors: initkfs
 */
class NullValidation : Validation
{
    this() @safe
    {
        super(new Logger, new ErrStatus);
    }
}
