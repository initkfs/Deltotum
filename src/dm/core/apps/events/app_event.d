module dm.core.apps.events.app_event;

import dm.core.events.event_base : EventBase;
import dm.core.utils.type_util : enumNameByIndex;

/**
 * Authors: initkfs
 */
struct AppEvent
{
    mixin EventBase;

    enum Event
    {
        none,
        exit
    }

    Event event;

    this(Event event, int ownerId = 0) pure @safe
    {
        this.event = event;
        this.ownerId = ownerId;
    }
}
