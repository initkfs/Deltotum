module deltotum.core.apps.events.application_event;

import deltotum.core.events.event_base : EventBase;
import deltotum.core.events.core_event_type : CoreEventType;
import deltotum.core.utils.type_util: eventNameByIndex;

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