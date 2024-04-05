module dm.kit.platforms.platform;

import dm.com.platforms.com_system : ComSystem;
import dm.core.components.units.services.application_unit : ApplicationUnit;
import dm.core.components.units.services.loggable_unit : LoggableUnit;
import dm.core.contexts.context : Context;
import dm.core.configs.config : Config;

import std.logger.core : Logger;

/**
 * Authors: initkfs
 */
class Platform : ApplicationUnit
{
    protected
    {
        ComSystem system;
    }

    this(ComSystem system, Logger logger, Config config, Context context) pure @safe
    {
        super(logger, config, context);

        assert(system);
        this.system = system;
    }

    void openURL(string url, bool isThrowOnOpen = false, bool isThrowOnInvalidUrl = false)
    {
        import std.uri : uriLength;

        immutable len = url.uriLength;
        if (len <= 0)
        {
            immutable errMessage = "Invalid URL received: " ~ url;
            if (isThrowOnInvalidUrl)
            {
                throw new Exception(errMessage);
            }
            else
            {
                logger.error(errMessage);
                return;
            }
        }

        if (const err = system.openURL(url))
        {
            immutable message = "Error opening url: " ~ err.toString;
            if (isThrowOnOpen)
            {
                throw new Exception(message);
            }
            
            logger.error(message);
        }
    }
}
