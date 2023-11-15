module dm.kit.inputs.pointers.events.pointer_event;

import dm.core.events.event_base : EventBase;
import dm.kit.events.kit_event_type: KitEventType;
import dm.core.utils.type_util : enumNameByIndex;
import dm.core.events.event_target : EventTarget;
import dm.core.events.event_source : EventSource;

/**
 * Authors: initkfs
 */
struct PointerEvent
{
    mixin EventBase;

    static enum Event
    {
        none,
        down,
        up,
        entered,
        exited,
        move,
        wheel
    }

    double x;
    double y;

    int button;

    double movementX;
    double movementY;

    this(int event, int ownerId, double x, double y, int button, double movementX, double movementY, bool isChained = true)
    {
        this.type = KitEventType.pointer;
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

        return format("{%s,%s,x:%s,y:%s,btn:%s,movX:%s,movY:%s,winid:%s,%s}", type, enumNameByIndex!Event(
                event), x, y, button, movementX, movementY, ownerId, isChained);
    }
}
