module dm.kit.i18n.langs.lang_messages;

import dm.core.components.units.services.loggable_unit : LoggableUnit;

import std.logger : Logger;

/**
 * Authors: initkfs
 */
class LangMessages
{

    protected
    {
        string[string][string] messages;
    }

    this(string[string][string] keyMessages)
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

    string get(string key, string langKey)
    {
        return messages[key][langKey];
    }

    override string toString() const
    {
        import std.format : format;

        return format("%s", messages);
    }
}
