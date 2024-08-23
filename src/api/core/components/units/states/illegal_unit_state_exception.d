module api.core.components.units.states.illegal_unit_state_exception;

import std.exception : basicExceptionCtors;

/**
 * Authors: initkfs
 */
class IllegalUnitStateException : Exception
{
    mixin basicExceptionCtors;
}
