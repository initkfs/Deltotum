module deltotum.physics.particles.config.json_emitter_config;

import deltotum.core.configs.attributes.configurable : Configurable;
import deltotum.physics.particles.config.emitter_config : EmitterConfig;
import deltotum.physics.particles.emitter : Emitter;

/**
 * Authors: initkfs
 * TODO fields from superclass
 */
class JsonEmitterConfig : EmitterConfig
{
    override string toConfig(Emitter emitter)
    {
        import std.traits : hasUDA, getUDAs;
        import std.json;

        if (emitter is null)
        {
            throw new Exception("Emitter must not be null");
        }

        JSONValue config;
        config.object = null;

        import deltotum.core.utils.meta: hasOverloads;

        static foreach (fieldName; __traits(allMembers, Emitter))
        {
            static if (!hasOverloads!(Emitter, fieldName) && hasUDA!(__traits(getMember, Emitter, fieldName), Configurable))
            {
                {
                    config.object[fieldName] = JSONValue(__traits(getMember, emitter, fieldName));
                }
            }
        }
        return config.toString;
    }

    override bool applyConfig(Emitter emitter, string config)
    {
        if (emitter is null)
        {
            throw new Exception("Emitter must not be null");
        }

        if (config.length == 0)
        {
            return false;
        }

        import std.json : parseJSON;
        import std.traits : hasUDA;
        import deltotum.core.utils.meta: hasOverloads;

        bool isApplied;

        auto json = parseJSON(config);
        static foreach (fieldName; __traits(allMembers, Emitter))
        {
            static if (!hasOverloads!(Emitter, fieldName) && hasUDA!(__traits(getMember, Emitter, fieldName), Configurable))
            {
                if (fieldName in json)
                {
                    alias fieldType = typeof(__traits(getMember, emitter, fieldName));
                    //TODO other types?
                    static if (is(fieldType == int))
                    {
                        auto jsonValue = json[fieldName].get!int;
                    }
                    else static if (is(fieldType == double))
                    {
                        auto jsonValue = json[fieldName].get!double;
                    }
                    __traits(getMember, emitter, fieldName) = jsonValue;
                    if (!isApplied)
                    {
                        isApplied = true;
                    }
                }
            }
        }

        return isApplied;
    }

}
