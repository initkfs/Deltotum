module deltotum.core.extensions.file_extension;

import deltotum.core.extensions.extension : Extension;
import deltotum.core.contexts.context : Context;
import deltotum.core.configs.config : Config;

import std.logger : Logger;

class FileExtension : Extension
{
    const string name;
    const string filePath;

    this(Logger logger, Config config, Context context, string name, string filePath)
    {
        super(logger, config, context);
        
        import std.exception : enforce;
        import std.string : strip;

        enforce(name !is null && name.strip.length > 0, "Extension name must not be empty");
        enforce(filePath !is null && filePath.strip.length > 0,
            "Extension file path must not be empty");

        this.name = name;
        this.filePath = filePath;
    }

}
