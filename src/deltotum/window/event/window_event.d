module deltotum.window.event.window_event;

import deltotum.events.event_base : EventBase;
import deltotum.events.event_type : EventType;
import deltotum.utils.type_util: eventNameByIndex;


/**
 * Authors: initkfs
 */
struct WindowEvent
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

    this(EventType type, uint event, uint windowId, double width, double height, double x, double y)
    {
        this.type = type;
        this.event = event;
        this.windowId = windowId;
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    string toString()
    {
        import std.format : format;

        return format("{%s,%s,x:%s,y:%s,w:%s,h:%s,winid:%s}", type, eventNameByIndex!Event(event), x, y, width, height, windowId);
    }
}
