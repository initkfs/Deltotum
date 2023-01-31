module deltotum.core.application.events.application_event;

import deltotum.core.events.event_base : EventBase;
import deltotum.core.events.event_type : EventType;
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

    this(EventType type, uint event, uint ownerId) pure @safe
    {
        this.type = type;
        this.event = event;
        this.ownerId = ownerId;
    }

    string toString() const
    {
        import std.format : format;

        return format("{%s,%s,ownid:%s}", type, eventNameByIndex!Event(event), ownerId);
    }
}
