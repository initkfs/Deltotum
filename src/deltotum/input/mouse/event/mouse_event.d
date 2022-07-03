module deltotum.input.mouse.event.mouse_event;

import deltotum.event.event_base : EventBase;
import deltotum.event.event_type : EventType;

immutable struct MouseEvent
{
    mixin EventBase;

    static enum Event
    {
        NONE,
        MOUSE_DOWN,
        MOUSE_UP,
        MOUSE_MOVE,
        MOUSE_WHEEL
    }

    double x;
    double y;

    int button;

    double movementX;
    double movementY;

    immutable this(EventType type, uint event, uint windowId, double x, double y, int button, double movementX, double movementY)
    {
        this.type = type;
        this.event = event;
        this.windowId = windowId;
        this.x = x;
        this.y = y;
        this.button = button;
        this.movementX = movementX;
        this.movementY = movementY;
    }

    string toString() immutable
    {
        import std.format : format;

        return format("{%s,%s,x:%s,y:%s,btn:%s,movX:%s,movY:%s,winid:%s}", type, getEventName!Event(
                event), x, y, button, movementX, movementY, windowId);
    }
}
