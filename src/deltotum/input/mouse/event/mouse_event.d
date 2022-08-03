module deltotum.input.mouse.event.mouse_event;

import deltotum.events.event_base : EventBase;
import deltotum.events.event_type : EventType;
import deltotum.utils.type_util : eventNameByIndex;
import deltotum.events.event_target : EventTarget;
import deltotum.events.event_source : EventSource;

/**
 * Authors: initkfs
 */
immutable struct MouseEvent
{
    mixin EventBase;

    static enum Event
    {
        none,
        mouseDown,
        mouseUp,
        mouseEntered,
        mouseExited,
        mouseMove,
        mouseWheel
    }

    double x;
    double y;

    int button;

    double movementX;
    double movementY;

    immutable this(EventType type, uint event, long windowId, double x, double y, int button, double movementX, double movementY, bool isChained = true)
    {
        this.type = type;
        this.event = event;
        this.windowId = windowId;
        this.x = x;
        this.y = y;
        this.button = button;
        this.movementX = movementX;
        this.movementY = movementY;
        this.isChained = isChained;
    }

    string toString() immutable
    {
        import std.format : format;

        return format("{%s,%s,x:%s,y:%s,btn:%s,movX:%s,movY:%s,winid:%s,%s}", type, eventNameByIndex!Event(
                event), x, y, button, movementX, movementY, windowId, isChained);
    }
}
