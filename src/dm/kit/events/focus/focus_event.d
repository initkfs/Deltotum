module dm.kit.events.focus.focus_event;

import dm.core.events.event_base : EventBase;
import dm.core.utils.type_util : enumNameByIndex;

/**
 * Authors: initkfs
 */
struct FocusEvent
{
    mixin EventBase;

    enum Event
    {
        none,
        focusIn,
        focusOut
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
