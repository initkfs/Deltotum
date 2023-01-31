module deltotum.engine.input.keyboard.event.key_event;

import deltotum.core.events.event_base : EventBase;
import deltotum.core.events.event_type : EventType;
import deltotum.core.utils.type_util: eventNameByIndex;

/**
 * Authors: initkfs
 */
struct KeyEvent
{
    mixin EventBase;

    static enum Event
    {
        none,
        keyDown,
        keyUp
    }

    int keyCode;
    int modifier;

    this(EventType type, uint event, uint ownerId, int keyCode, int modifier)
    {
        this.type = type;
        this.event = event;
        this.ownerId = ownerId;
        this.keyCode = keyCode;
        this.modifier = modifier;
    }

    string toString()
    {
        import std.format : format;

        return format("{%s,%s,code:%s,mod:%s,winid:%s}", type, eventNameByIndex!Event(event), keyCode, modifier, ownerId);
    }
}
