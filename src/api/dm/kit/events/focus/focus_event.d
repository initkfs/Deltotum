module api.dm.kit.events.focus.focus_event;

import api.core.events.base.event_base : EventBase;
import api.core.utils.types : enumNameByIndex;

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
