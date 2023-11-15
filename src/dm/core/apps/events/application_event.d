module dm.core.apps.events.application_event;

import dm.core.events.event_base : EventBase;
import dm.core.events.core_event_type : CoreEventType;
import dm.core.utils.type_util: enumNameByIndex;

/**
 * Authors: initkfs
 */
struct ApplicationEvent
{
    mixin EventBase;

    static enum Event
    {
        None,
        Exit
    }

    this(int event, int ownerId = 0) pure @safe
    {
        this.type = CoreEventType.application;
        this.event = event;
        this.ownerId = ownerId;
    }
}