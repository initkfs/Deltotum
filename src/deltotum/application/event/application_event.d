module deltotum.application.event.application_event;

import deltotum.events.event_base : EventBase;
import deltotum.events.event_type : EventType;
import deltotum.utils.type_util: eventNameByIndex;

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

    immutable this(immutable EventType type, uint event, uint windowId)
    {
        this.type = type;
        this.event = event;
        this.windowId = windowId;
    }

    string toString() immutable
    {
        import std.format : format;

        return format("{%s,%s,winid:%s}", type, eventNameByIndex!Event(event), windowId);
    }
}
