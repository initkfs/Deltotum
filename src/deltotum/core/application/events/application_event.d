module deltotum.core.application.events.application_event;

import deltotum.engine.events.event_base : EventBase;
import deltotum.engine.events.event_type : EventType;
import deltotum.core.utils.type_util: eventNameByIndex;

/**
 * Authors: initkfs
 */
struct ApplicationEvent
{
    mixin EventBase;

    static enum Event
    {
        NONE,
        EXIT
    }

    this(EventType type, uint event, uint windowId) pure @safe
    {
        this.type = type;
        this.event = event;
        this.windowId = windowId;
    }

    string toString() const
    {
        import std.format : format;

        return format("{%s,%s,winid:%s}", type, eventNameByIndex!Event(event), windowId);
    }
}
