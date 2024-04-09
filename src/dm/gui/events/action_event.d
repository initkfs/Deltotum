module dm.gui.events.action_event;

import dm.core.events.event_base : EventBase;
import dm.kit.events.kit_event_type: KitEventType;
import dm.core.utils.type_util : enumNameByIndex;
import dm.core.events.event_target : EventTarget;
import dm.core.events.event_source : EventSource;

/**
 * Authors: initkfs
 */
struct ActionEvent
{
    mixin EventBase;

    static enum Event
    {
        none,
        action
    }

    Event event;

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
