module api.core.events.bus.core_bus_events;

import std.variant: Variant;

/**
 * Authors: initkfs
 */
enum CoreBusEvents {
    build_event_bus = "build_event_bus",
    build_context = "build_context",
    build_configs = "build_configs",
    build_logging = "build_logging",
    build_resourcing = "build_resourcing",
    build_memory = "build_memory",
    
    build_core_services = "build_core_services"
}