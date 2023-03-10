module deltotum.core.configs.exceptions.config_value_incorrect_exception;
/**
 * Authors: initkfs
 */
class ConfigValueIncorrectException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }
}
