module api.dm.kit.inputs.keyboards.events.text_input_event;

import api.core.events.base.event_base : EventBase;
import api.core.utils.types : enumNameByIndex;

/**
 * Authors: initkfs
 */
struct TextInputEvent
{
    mixin EventBase;

    enum Event
    {
        none,
        input,
    }

    Event event;

    dchar firstLetter;

    this(Event event, int ownerId, dchar firstLetter)
    {
        this.event = event;
        this.ownerId = ownerId;
        this.firstLetter = firstLetter;
    }

    string toString() const
    {
        import std.format : format;

        return format("{%s,%s,text:%s,winid:%s}", enumNameByIndex!Event(event), firstLetter, ownerId);
    }
}
