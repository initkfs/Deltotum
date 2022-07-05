module deltotum.input.keyboard.event.key_event;

import deltotum.event.event_base : EventBase;
import deltotum.event.event_type : EventType;

/**
 * Authors: initkfs
 */
immutable struct KeyEvent
{
    mixin EventBase;

    static enum Event
    {
        NONE,
        KEY_DOWN,
        KEY_UP
    }

    int keyCode;
    int modifier;

    immutable this(EventType type, uint event, uint windowId, int keyCode, int modifier)
    {
        this.type = type;
        this.event = event;
        this.windowId = windowId;
        this.keyCode = keyCode;
        this.modifier = modifier;
    }

    string toString() immutable
    {
        import std.format : format;

        return format("{%s,%s,code:%s,mod:%s,winid:%s}", type, getEventName!Event(event), keyCode, modifier, windowId);
    }
}
