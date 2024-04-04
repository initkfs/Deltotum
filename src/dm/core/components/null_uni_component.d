module dm.core.components.null_uni_component;

import dm.core.components.uni_component : UniComponent;
import dm.core.contexts.null_context : NullContext;
import dm.core.configs.null_config : NullConfig;
import dm.core.clis.null_cli : NullCli;
import dm.core.resources.null_resource : NullResource;
import dm.core.supports.null_support : NullSupport;
import dm.core.events.bus.null_event_bus : NullEventBus;
import dm.core.locators.null_service_locator : NullServiceLocator;

import dm.core.apps.caps.cap_core : CapCore;

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
    import dm.core.utils.type_util : hasOverloads;
    import dm.core.components.attributes : Service;

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
