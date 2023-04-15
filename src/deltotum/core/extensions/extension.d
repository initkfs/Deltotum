module deltotum.core.extensions.extension;

import deltotum.core.applications.components.units.services.application_unit : ApplicationUnit;
import deltotum.core.contexts.context : Context;
import deltotum.core.configs.config : Config;

import std.logger : Logger;

abstract class Extension : ApplicationUnit
{

    this(Logger logger, Config config, Context context)
    {
        super(logger, config, context);
    }

    abstract
    {
        bool load();
        string[] call(string event, string[] args);
    }
}
