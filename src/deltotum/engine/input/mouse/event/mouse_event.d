module deltotum.engine.input.mouse.event.mouse_event;

import deltotum.core.events.event_base : EventBase;
import deltotum.core.events.event_type : EventType;
import deltotum.core.utils.type_util : eventNameByIndex;
import deltotum.core.events.event_target : EventTarget;
import deltotum.core.events.event_source : EventSource;

/**
 * Authors: initkfs
 */
struct MouseEvent
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

    this(EventType type, uint event, long ownerId, double x, double y, int button, double movementX, double movementY, bool isChained = true)
    {
        this.type = type;
        this.event = event;
        this.ownerId = ownerId;
        this.x = x;
        this.y = y;
        this.button = button;
        this.movementX = movementX;
        this.movementY = movementY;
        this.isChained = isChained;
    }

    string toString()
    {
        import std.format : format;

        return format("{%s,%s,x:%s,y:%s,btn:%s,movX:%s,movY:%s,winid:%s,%s}", type, eventNameByIndex!Event(
                event), x, y, button, movementX, movementY, ownerId, isChained);
    }
}
