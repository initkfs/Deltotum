module api.dm.gui.events.action_event;

import api.core.utils.types : enumNameByIndex;
import api.core.events.base.event_target : EventTarget;
import api.core.events.base.event_source : EventSource;

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

    bool isSynthetic;
    bool isConsumed;
    bool isConsumeAfterDispatch;

    int ownerId;

    bool isInBounds = true;

    this(int ownerId, double x, double y, int button)
    {
        this.event = Event.action;
        this.ownerId = ownerId;
        this.x = x;
        this.y = y;
        this.button = button;
    }
}
