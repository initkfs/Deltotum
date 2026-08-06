module api.dm.kit.events.dnd.dnd_event;

import api.dm.kit.events.event_base : EventBase;

/**
 * Authors: initkfs
 */
struct DNDEvent
{
    mixin EventBase;

    enum Event
    {
        start,
        wait,
        cancel,
        drop,
    }

    Event event;
    float x = 0;
    float y = 0;

    this(Event event, float x, float y, int ownerId)
    {
        this.event = event;
        this.x = x;
        this.y = y;
        this.ownerId  = ownerId;

        //isSynthetic = true;
    }
}
