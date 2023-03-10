module deltotum.core.configs.exceptions.config_value_notfound_exception;
/**
 * Authors: initkfs
 */
class ConfigValueNotFoundException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }
}
