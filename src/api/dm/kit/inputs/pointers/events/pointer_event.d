module api.dm.kit.inputs.pointers.events.pointer_event;

import api.dm.kit.events.event_base : EventBase;
import api.dm.kit.events.event_target : EventTarget;
import api.dm.kit.events.event_source : EventSource;

/**
 * Authors: initkfs
 */
struct PointerEvent
{
    mixin EventBase;

    enum Event
    {
        none,
        cancel,
        press,
        release,
        enter,
        exit,
        move,
        wheel,

        click
    }

    Event event;

    float x = 0;
    float y = 0;

    int button;

    float movementX;
    float movementY;

    bool isPrimary = true;

    this(Event event, int ownerId = 0, float x = 0, float y = 0, int button = 0, float movementX = 0, float movementY = 0)
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

        return format("{%s,x:%s,y:%s,btn:%s,movX:%s,movY:%s,winid:%s,%s}", event, x, y, button, movementX, movementY, ownerId, isSynthetic);
    }
}
