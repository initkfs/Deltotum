module api.core.events.event_bridge;

import api.core.components.component_service : ComponentService;
import api.core.events.bus.event_bus : EventBus;

/**
 * Authors: initkfs
 */
class EventBridge : ComponentService
{

    EventBus eventBus;

    this(EventBus bus)
    {
        assert(bus);
        this.eventBus = bus;
    }
}
