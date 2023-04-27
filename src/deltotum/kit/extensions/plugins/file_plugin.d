module deltotum.kit.extensions.plugins.file_plugin;

import deltotum.kit.extensions.plugins.plugin : Plugin;
import deltotum.core.contexts.context : Context;
import deltotum.core.configs.config : Config;

import std.logger : Logger;

class FilePlugin : Plugin
{
    const string filePath;

    this(Logger logger, Config config, Context context, string name, string filePath)
    {
        super(logger, config, context, name);

        import std.exception : enforce;
        import std.string : strip;

        enforce(filePath !is null && filePath.strip.length > 0,
            "Extension file path must not be empty");
        this.filePath = filePath;
    }
}
