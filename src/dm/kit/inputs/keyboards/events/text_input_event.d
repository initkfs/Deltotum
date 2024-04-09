module dm.kit.inputs.keyboards.events.text_input_event;

import dm.core.events.event_base : EventBase;
import dm.kit.events.kit_event_type: KitEventType;
import dm.core.utils.type_util : enumNameByIndex;

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

    Event event;

    dchar firstLetter;

    this(Event event, uint ownerId, dchar firstLetter)
    {
        this.type = KitEventType.key;
        this.event = event;
        this.ownerId = ownerId;
        this.firstLetter = firstLetter;
    }

    string toString() const
    {
        import std.format : format;

        return format("{%s,%s,text:%s,winid:%s}", type, enumNameByIndex!Event(event), firstLetter, ownerId);
    }
}
