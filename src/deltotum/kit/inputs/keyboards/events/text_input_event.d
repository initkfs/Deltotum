module deltotum.kit.inputs.keyboards.events.text_input_event;

import deltotum.core.events.event_base : EventBase;
import deltotum.kit.events.kit_event_type: KitEventType;
import deltotum.core.utils.type_util : enumNameByIndex;

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

    this(int event, uint ownerId, dchar firstLetter)
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
