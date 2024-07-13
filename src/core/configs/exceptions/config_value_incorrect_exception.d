module core.configs.exceptions.config_value_incorrect_exception;

import std.exception : basicExceptionCtors;

/**
 * Authors: initkfs
 */
class ConfigValueIncorrectException : Exception
{
    mixin basicExceptionCtors;
}
