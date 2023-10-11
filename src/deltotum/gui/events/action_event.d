module deltotum.gui.events.action_event;

import deltotum.core.events.event_base : EventBase;
import deltotum.kit.events.kit_event_type: KitEventType;
import deltotum.core.utils.type_util : eventNameByIndex;
import deltotum.core.events.event_target : EventTarget;
import deltotum.core.events.event_source : EventSource;

/**
 * Authors: initkfs
 */
struct ActionEvent
{
    mixin EventBase;

    static enum Event
    {
        action
    }

    double x;
    double y;

    int button;

    this(int ownerId, double x, double y, int button)
    {
        this.type = KitEventType.action;
        this.event = Event.action;
        this.ownerId = ownerId;
        this.x = x;
        this.y = y;
        this.button = button;
    }
}
