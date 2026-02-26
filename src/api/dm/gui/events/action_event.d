module api.dm.gui.events.action_event;

import api.dm.kit.events.event_target : EventTarget;
import api.dm.kit.events.event_source : EventSource;

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

    float x;
    float y;

    int button;

    EventSource source;
    EventTarget target;

    bool isSynthetic;
    bool isConsumed;
    bool isConsumeAfterDispatch;

    int ownerId;

    bool isInBounds = true;

    this(int ownerId, float x, float y, int button)
    {
        this.event = Event.action;
        this.ownerId = ownerId;
        this.x = x;
        this.y = y;
        this.button = button;
    }
}
