module api.dm.kit.i18n.langs.validators.lang_key_validator;

import api.core.validations.validators.validator : Validator;
import api.dm.kit.i18n.i18n: I18n;

/**
 * Authors: initkfs
 * 
 */

class LangKeyValidator : Validator
{
    I18n i18n;
    string[] _keys;

    this(I18n i18n, string[] keys)
    {
        if (!i18n)
        {
            throw new Exception("I18n must not be null");
        }

        this.i18n = i18n;
        this._keys = keys;

        name = "Lang key validator";
    }

    override void validate()
    {
        setValid;

        foreach (string key; _keys)
        {
            if (!i18n.hasMessage(key))
            {
                addFail("Not found language message with key: " ~ key);
            }
        }
    }

}
