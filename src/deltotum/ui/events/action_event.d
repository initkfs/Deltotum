module deltotum.ui.events.action_event;

import deltotum.core.events.event_base : EventBase;
import deltotum.core.events.event_type : EventType;
import deltotum.core.utils.type_util : eventNameByIndex;
import deltotum.core.events.event_target : EventTarget;
import deltotum.core.events.event_source : EventSource;

/**
 * Authors: initkfs
 */
struct ActionEvent
{
    mixin EventBase;

    static enum Event
    {
        action
    }

    double x;
    double y;

    int button;

    this(long ownerId, double x, double y, int button)
    {
        this.type = EventType.action;
        this.event = Event.action;
        this.x = x;
        this.y = y;
        this.button = button;
    }

    string toString()
    {
        import std.format : format;

        return format("{%s,%s,x:%s,y:%s,btn:%s,movX:%s,movY:%s,winid:%s}", type, eventNameByIndex!Event(
                event), x, y, button, ownerId);
    }
}
