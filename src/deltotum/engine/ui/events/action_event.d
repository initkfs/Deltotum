module deltotum.engine.ui.events.action_event;

import deltotum.engine.events.event_base : EventBase;
import deltotum.engine.events.event_type : EventType;
import deltotum.core.utils.type_util : eventNameByIndex;
import deltotum.engine.events.event_target : EventTarget;
import deltotum.engine.events.event_source : EventSource;

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

    this(long windowId, double x, double y, int button)
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
                event), x, y, button, windowId);
    }
}
