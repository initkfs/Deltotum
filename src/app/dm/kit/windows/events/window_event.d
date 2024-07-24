module app.dm.kit.windows.events.window_event;

import app.core.events.event_base : EventBase;
import app.core.utils.types: enumNameByIndex;


/**
 * Authors: initkfs
 */
struct WindowEvent
{
    mixin EventBase;

    enum Event
    {
        none,
        show,
        hide,
        enter,
        expose,
        close,
        deactivate,
        focusIn,
        focusOut,
        leave,
        maximize,
        minimize,
        move,
        resize,
        restore
    }

    long width;
    long height;
    long x;
    long y;

    Event event;

    this(Event event, int ownerId, long width, long height, long x, long y)
    {
        this.event = event;
        this.ownerId = ownerId;
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    string toString() const
    {
        import std.format : format;

        return format("{%s,x:%s,y:%s,w:%s,h:%s,winid:%s}", enumNameByIndex!Event(event), x, y, width, height, ownerId);
    }
}
