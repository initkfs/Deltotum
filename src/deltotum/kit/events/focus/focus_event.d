module deltotum.kit.sprites.events.focus.focus_event;

import deltotum.core.events.event_base : EventBase;
import deltotum.kit.events.kit_event_type: KitEventType;
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

    this(int event, int ownerId, double x, double y)
    {
        this.type = KitEventType.focus;
        this.event = event;
        this.ownerId = ownerId;
        this.x  = x;
        this.y = y;
    }
}
