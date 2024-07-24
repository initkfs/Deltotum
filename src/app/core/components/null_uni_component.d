module app.core.components.null_uni_component;

import app.core.components.uni_component : UniComponent;
import app.core.contexts.null_context : NullContext;
import app.core.configs.null_config : NullConfig;
import app.core.clis.null_cli : NullCli;
import app.core.resources.null_resource : NullResource;
import app.core.supports.null_support : NullSupport;
import app.core.events.bus.null_event_bus : NullEventBus;
import app.core.locators.null_service_locator : NullServiceLocator;
import app.core.mem.mallocator: Mallocator;

import app.core.apps.caps.cap_core : CapCore;

import std.logger.nulllogger : NullLogger;

/**
 * Authors: initkfs
 */
class NullUniComponent : UniComponent
{

    this()
    {
        _context = new NullContext;
        _logger = new NullLogger;
        _config = new NullConfig;
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
    import app.core.utils.types : hasOverloads;
    import app.core.components.attributes : Service;

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
