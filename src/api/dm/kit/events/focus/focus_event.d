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

    double x = 0;
    double y = 0;

    this(Event event, int ownerId, double x, double y)
    {
        this.event = event;
        this.ownerId = ownerId;
        this.x  = x;
        this.y = y;
    }
}
