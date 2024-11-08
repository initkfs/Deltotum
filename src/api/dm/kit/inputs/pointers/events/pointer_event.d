module api.dm.kit.inputs.pointers.events.pointer_event;

import api.core.events.base.event_base : EventBase;
import api.core.utils.types : enumNameByIndex;
import api.core.events.base.event_target : EventTarget;
import api.core.events.base.event_source : EventSource;

/**
 * Authors: initkfs
 */
struct PointerEvent
{
    mixin EventBase;

    enum Event
    {
        none,
        down,
        up,
        entered,
        exited,
        move,
        wheel
    }

    Event event;

    double x = 0;
    double y = 0;

    int button;

    double movementX;
    double movementY;

    this(Event event, int ownerId = 0, double x = 0, double y = 0, int button = 0, double movementX = 0, double movementY = 0)
    {
        this.event = event;
        this.ownerId = ownerId;
        this.x = x;
        this.y = y;
        this.button = button;
        this.movementX = movementX;
        this.movementY = movementY;
    }

    string toString()
    {
        import std.format : format;

        return format("{%s,x:%s,y:%s,btn:%s,movX:%s,movY:%s,winid:%s,%s}", enumNameByIndex!Event(
                event), x, y, button, movementX, movementY, ownerId, isSynthetic);
    }
}
