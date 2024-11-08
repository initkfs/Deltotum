module api.core.events.bus.core_bus_events;

import std.variant: Variant;

/**
 * Authors: initkfs
 */
enum CoreBusEvents {
    build_event_bus = "build_event_bus",
    build_context = "build_context",
    build_config = "build_config",
    build_logging = "build_logging",
    build_resource = "build_resource",
    build_allocator = "build_allocator",
    build_locator = "build_locator",

    build_core_services = "build_core_services"
}