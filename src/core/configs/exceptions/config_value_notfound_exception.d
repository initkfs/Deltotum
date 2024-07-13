module core.configs.exceptions.config_value_notfound_exception;

import std.exception : basicExceptionCtors;

/**
 * Authors: initkfs
 */
class ConfigValueNotFoundException : Exception
{
    mixin basicExceptionCtors;
}
