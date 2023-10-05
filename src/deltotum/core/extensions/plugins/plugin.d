module deltotum.core.extensions.plugins.plugin;

import deltotum.core.apps.units.services.application_unit : ApplicationUnit;
import deltotum.core.contexts.context : Context;
import deltotum.core.configs.config : Config;

import std.logger : Logger;
import std.variant: Variant;

abstract class Plugin : ApplicationUnit
{
    const string name;
    
    string workDirPath;

    this(Logger logger, Config config, Context context, const string name)
    {
        super(logger, config, context);

        import std.exception : enforce;
        import std.string : strip;

        enforce(name !is null && name.strip.length > 0, "Plugin name must not be empty");
        this.name = name;
    }

    abstract
    {
        void call(string[] args, void delegate(Variant) onResult, void delegate(string) onError);
    }
}
