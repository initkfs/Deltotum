module api.dm.kit.events.focus.focus_event;

import api.dm.kit.events.event_base : EventBase;

/**
 * Authors: initkfs
 */
struct FocusEvent
{
    mixin EventBase;

    enum Event
    {
        none,
        enter,
        exit
    }

    Event event;

    this(Event event, int ownerId)
    {
        this.event = event;
        this.ownerId = ownerId;
    }
}
