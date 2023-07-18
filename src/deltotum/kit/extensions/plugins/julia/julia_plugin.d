module deltotum.kit.extensions.plugins.julia.julia_plugin;

import deltotum.kit.extensions.plugins.plugin : Plugin;
import deltotum.core.contexts.context : Context;
import deltotum.core.configs.config : Config;

import std.logger : Logger;

import std.variant : Variant;

abstract class JuliaPlugin : Plugin
{
    this(Logger logger, Config config, Context context, const string name)
    {
        super(logger, config, context, name);
    }
}
