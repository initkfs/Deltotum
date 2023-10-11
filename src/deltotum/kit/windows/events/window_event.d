module deltotum.kit.windows.events.window_event;

import deltotum.core.events.event_base : EventBase;
import deltotum.kit.events.kit_event_type: KitEventType;
import deltotum.core.utils.type_util: eventNameByIndex;


/**
 * Authors: initkfs
 */
struct WindowEvent
{
    mixin EventBase;

    static enum Event
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

    this(int event, int ownerId, long width, long height, long x, long y)
    {
        this.type = KitEventType.window;
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

        return format("{%s,%s,x:%s,y:%s,w:%s,h:%s,winid:%s}", type, eventNameByIndex!Event(event), x, y, width, height, ownerId);
    }
}
