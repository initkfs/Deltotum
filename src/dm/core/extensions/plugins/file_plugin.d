module dm.core.extensions.plugins.file_plugin;

import dm.core.extensions.plugins.plugin : Plugin;
import dm.core.contexts.context : Context;
import dm.core.configs.config : Config;

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
