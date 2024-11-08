module api.core.components.null_uni_component;

import api.core.components.uni_component : UniComponent;
import api.core.loggers.null_logging: NullLogging;
import api.core.contexts.null_context : NullContext;
import api.core.configs.null_configuration: NullConfiguration;
import api.core.clis.null_cli : NullCli;
import api.core.resources.null_resource : NullResource;
import api.core.supports.null_support : NullSupport;
import api.core.events.bus.null_event_bus : NullEventBus;
import api.core.locators.null_service_locator : NullServiceLocator;
import api.core.mem.mallocator: Mallocator;

import api.core.apps.caps.cap_core : CapCore;


/**
 * Authors: initkfs
 */
class NullUniComponent : UniComponent
{

    this()
    {
        _context = new NullContext;
        _logging = new NullLogging;
        _configs = new NullConfiguration;
        //TODO NullAllocator?
        _alloc = new Mallocator;
        _cli = new NullCli;
        _resource = new NullResource;
        _support = new NullSupport;
        _capCore = new CapCore;
        _eventBus = new NullEventBus;
        _locator = new NullServiceLocator;
        isBuilt = true;
    }
}

unittest
{
    auto nc1 = new NullUniComponent;

    auto nc = new UniComponent;
    nc1.buildInitCreateRun(nc);
    assert(nc.isBuilt);

    import std.traits : hasUDA;
    import api.core.utils.types : hasOverloads;
    import api.core.components.uda : Service;

    alias componentType = typeof(nc);
    static foreach (const fieldName; __traits(allMembers, componentType))
    {
        static if (!hasOverloads!(componentType, fieldName) && hasUDA!(__traits(getMember, componentType, fieldName), Service))
        {
            {
                auto value = __traits(getMember, nc, fieldName);
                assert(value, "Service is null in field: " ~ fieldName);
            }
        }
    }

    nc1.stopDispose(nc);
    assert(nc.isDisposed);
}
