module api.dm.kit.inputs.joysticks.events.joystick_event;

import api.dm.kit.events.event_base : EventBase;

/**
 * Authors: initkfs
 */
struct JoystickEvent
{
    mixin EventBase;

    enum Event
    {
        none,
        axis,
        press,
        release
    }

    Event event;

    int button;
    bool isDown;
    int axis;
    int axisValue;

    this(Event event, uint ownerId, int button = 0, bool isDown, int axis = 0, int axisValue = 0)
    {
        this.event = event;
        this.ownerId = ownerId;
        this.button = button;
        this.isDown = isDown;
        this.axis = axis;
        this.axisValue = axisValue;
    }
}
