module deltotum.kit.display.events.focus.focus_event;

import deltotum.core.events.event_base : EventBase;
import deltotum.core.events.event_type : EventType;
import deltotum.core.utils.type_util : eventNameByIndex;
import deltotum.core.events.event_target : EventTarget;
import deltotum.core.events.event_source : EventSource;

/**
 * Authors: initkfs
 */
struct FocusEvent
{
    mixin EventBase;

    static enum Event
    {
        none,
        focusIn,
        focusOut
    }

    double x = 0;
    double y = 0;

    this(EventType type, uint event, long ownerId, double x, double y, bool isChained = true)
    {
        this.type = type;
        this.event = event;
        this.ownerId = ownerId;
        this.x  = x;
        this.y = y;
        this.isChained = isChained;
    }
}
