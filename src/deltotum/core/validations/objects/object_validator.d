module deltotum.core.validations.objects.object_validator;

import deltotum.core.validations.validator : Validator;

/**
 * Authors: initkfs
 */
abstract class ObjectValidator(T : Object) : Validator
{
    protected
    {
        T obj;
    }

    this(T obj) @safe pure
    {
        import std.exception : enforce;

        enforce(obj !is null, "Object for validation must not be null");
        this.obj = obj;
    }
}
