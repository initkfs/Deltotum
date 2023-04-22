module deltotum.kit.input.keyboard.event.text_input_event;

import deltotum.core.events.event_base : EventBase;
import deltotum.core.events.event_type : EventType;
import deltotum.core.utils.type_util : eventNameByIndex;

/**
 * Authors: initkfs
 */
struct TextInputEvent
{
    mixin EventBase;

    static enum Event
    {
        none,
        input,
    }

    dchar firstLetter;

    this(EventType type, uint event, uint ownerId, dchar firstLetter)
    {
        this.type = type;
        this.event = event;
        this.ownerId = ownerId;
        this.firstLetter = firstLetter;
    }

    string toString() const
    {
        import std.format : format;

        return format("{%s,%s,text:%s,winid:%s}", type, eventNameByIndex!Event(event), firstLetter, ownerId);
    }
}
