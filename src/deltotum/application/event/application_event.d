module deltotum.application.event.application_event;

import deltotum.event.event_base : EventBase;
import deltotum.event.event_type : EventType;

/**
 * Authors: initkfs
 */
immutable struct ApplicationEvent
{
    mixin EventBase;

    static enum Event
    {
        NONE,
        EXIT
    }

    immutable this(EventType type, uint event, uint windowId)
    {
        this.type = type;
        this.event = event;
        this.windowId = windowId;
    }

    string toString() immutable
    {
        import std.format : format;

        return format("{%s,%s,winid:%s}", type, getEventName!Event(event), windowId);
    }
}
