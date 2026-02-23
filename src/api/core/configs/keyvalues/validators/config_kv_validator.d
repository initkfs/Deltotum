module api.core.configs.keyvalues.validators.config_kv_validator;

import api.core.validations.validators.validator : Validator;
import api.core.configs.keyvalues.config : Config;

/**
 * Authors: initkfs
 * 
 */

class ConfigKValidator : Validator
{
    Config _config;
    string[] _keys;

    this(Config config, string[] keys)
    {
        if (!config)
        {
            throw new Exception("Config must not be null");
        }

        this._config = config;
        this._keys = keys;
    }

    override void validate()
    {
        setValid;

        foreach (string key; _keys)
        {
            if (!_config.hasKey(key))
            {
                addFail("Not found key in config: " ~ key);
            }
        }
    }

}
