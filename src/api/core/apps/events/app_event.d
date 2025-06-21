module api.core.apps.events.app_event;

import api.core.events.event_base : EventBase;
import api.core.utils.types : enumNameByIndex;

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
