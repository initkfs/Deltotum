module api.dm.kit.i18n.langs.lang_messages;

import api.core.components.units.services.loggable_unit : LoggableUnit;

import api.core.loggers.logging : Logging;

/**
 * Authors: initkfs
 */
class LangMessages
{

    protected
    {
        dstring[string][string] messages;
    }

    this(dstring[string][string] keyMessages)
    {
        this.messages = keyMessages;
    }

    bool hasKey(string key)
    {
        //TODO return ptr
        return (key in messages) !is null;
    }

    bool hasLangKey(string key, string langKey)
    {
        if (!hasKey(key))
        {
            return false;
        }
        return (langKey in messages[key]) !is null;
    }

    dstring get(string key, string langKey)
    {
        return messages[key][langKey];
    }

    override string toString() const
    {
        import std.format : format;

        return format("%s", messages);
    }
}
