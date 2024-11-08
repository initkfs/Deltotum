module api.core.events.null_event_bridge;

import api.core.events.event_bridge: EventBridge;
import api.core.events.bus.null_event_bus: NullEventBus;

/**
 * Authors: initkfs
 */
class NullEventBridge : EventBridge
{
    this()
    {
        super(new NullEventBus);
    }
}
