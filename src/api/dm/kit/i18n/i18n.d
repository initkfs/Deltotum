module api.dm.kit.i18n.i18n;

import api.core.components.units.services.loggable_unit : LoggableUnit;
import api.dm.kit.i18n.langs.lang_messages : LangMessages;

import std.logger : Logger;

/**
 * Authors: initkfs
 */
class I18n : LoggableUnit
{
    LangMessages[] langMessages;
    string lang;

    enum errorMessage = "%i18n_error%";

    this(Logger logger) pure @safe
    {
        super(logger);
    }

    dstring getMessage(string key, dstring defaultMessage = errorMessage)
    {
        if (key.length == 0)
        {
            logger.error("Received empty i18n key", errorMessage);
            return defaultMessage;
        }

        if (lang.length == 0)
        {
            logger.error("Language is empty for key ", key);
            return defaultMessage;
        }

        foreach (LangMessages message; langMessages)
        {
            if (message.hasLangKey(key, lang))
            {
                dstring result = message.get(key, lang);
                return result;
            }
        }

        logger.tracef("Not found i18n key '%s' for language '%s'", key, lang);
        return defaultMessage;
    }
}
