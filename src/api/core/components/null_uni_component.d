module api.core.components.null_uni_component;

import api.core.components.uni_component : UniComponent;
import api.core.loggers.null_logging: NullLogging;
import api.core.contexts.null_context : NullContext;
import api.core.configs.null_configuration: NullConfiguration;
import api.core.clis.null_cli : NullCli;
import  api.core.validations.null_validation: NullValidation;;
import api.core.mems.null_memory: NullMemory;

/**
 * Authors: initkfs
 */
class NullUniComponent : UniComponent
{

    this() @safe
    {
        _context = new NullContext;
        _logging = new NullLogging;
        _configs = new NullConfiguration;
        _memory = new NullMemory;
        _cli = new NullCli;
        _validation = NullValidation;
        isBuilt = true;
    }
}

unittest
{
    auto nc1 = new NullUniComponent;

    auto nc = new UniComponent;
    nc1.buildInitCreateRun(nc);
    assert(nc.isBuilt);

    import std.traits : hasUDA, hasStaticMember;
    import api.core.utils.types : hasOverloads;
    import api.core.components.component_service : Service;

    alias componentType = typeof(nc);
    static foreach (const fieldName; __traits(allMembers, componentType))
    {
        static if (!hasOverloads!(componentType, fieldName) && hasUDA!(__traits(getMember, componentType, fieldName), Service) && !hasStaticMember!(componentType, fieldName))
        {
            {
                auto value = __traits(getMember, nc, fieldName);
                assert(value, "Service is null in field: " ~ fieldName);
            }
        }
    }

    nc1.stopDispose(nc);
    assert(nc.isDisposing);
}
