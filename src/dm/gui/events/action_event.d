module dm.gui.events.action_event;

import dm.core.utils.type_util : enumNameByIndex;
import dm.core.events.event_target : EventTarget;
import dm.core.events.event_source : EventSource;

/**
 * Authors: initkfs
 */
struct ActionEvent
{
    enum Event
    {
        none,
        action
    }

    Event event;

    double x;
    double y;

    int button;

    EventSource source;
    EventTarget target;

    bool isChained = true;
    bool isConsumed;

    int ownerId;

    this(int ownerId, double x, double y, int button)
    {
        this.event = Event.action;
        this.ownerId = ownerId;
        this.x = x;
        this.y = y;
        this.button = button;
    }
}
