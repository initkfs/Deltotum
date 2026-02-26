module api.dm.kit.apps.events.app_event;

import api.dm.kit.events.event_base : EventBase;

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
