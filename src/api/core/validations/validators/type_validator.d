module api.core.validations.validators.type_validator;

import api.core.validations.validators.validator : Validator;

/**
 * Authors: initkfs
 */
abstract class TypeValidator(T) : Validator
{
    protected
    {
        T target;
    }

    this(T target) pure @safe
    {
        this.target = target;
    }
}
