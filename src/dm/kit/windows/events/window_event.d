module dm.kit.windows.events.window_event;

import dm.core.events.event_base : EventBase;
import dm.kit.events.kit_event_type: KitEventType;
import dm.core.utils.type_util: enumNameByIndex;


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

    Event event;

    this(Event event, int ownerId, long width, long height, long x, long y)
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

        return format("{%s,%s,x:%s,y:%s,w:%s,h:%s,winid:%s}", type, enumNameByIndex!Event(event), x, y, width, height, ownerId);
    }
}
