module deltotum.window.event.window_event;

import deltotum.event.event_base : EventBase;
import deltotum.event.event_type : EventType;

/**
 * Authors: initkfs
 */
immutable struct WindowEvent
{
    mixin EventBase;

    static enum Event
    {
        NONE,
        WINDOW_SHOW,
        WINDOW_HIDE,
        WINDOW_ENTER,
        WINDOW_EXPOSE,
        WINDOW_CLOSE,
        WINDOW_DEACTIVATE,
        WINDOW_FOCUS_IN,
        WINDOW_FOCUS_OUT,
        WINDOW_LEAVE,
        WINDOW_MAXIMIZE,
        WINDOW_MINIMIZE,
        WINDOW_MOVE,
        WINDOW_RESIZE,
        WINDOW_RESTORE,
    }

    double width;
    double height;
    double x;
    double y;

    immutable this(EventType type, uint event, uint windowId, double width, double height, double x, double y)
    {
        this.type = type;
        this.event = event;
        this.windowId = windowId;
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    string toString() immutable
    {
        import std.format : format;

        return format("{%s,%s,x:%s,y:%s,w:%s,h:%s,winid:%s}", type, getEventName!Event(event), x, y, width, height, windowId);
    }
}
