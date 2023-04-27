module deltotum.kit.inputs.joystick.event.joystick_event;

import deltotum.core.events.event_base : EventBase;
import deltotum.core.events.event_type : EventType;
import deltotum.core.utils.type_util : eventNameByIndex;

/**
 * Authors: initkfs
 */
struct JoystickEvent
{
    mixin EventBase;

    static enum Event
    {
        none,
        axis,
        press,
        release
    }

    int button;
    int axis;
    int axisValue;

    this(EventType type, uint event, uint ownerId, int button = 0, int axis = 0, int axisValue = 0)
    {
        this.type = type;
        this.event = event;
        this.ownerId = ownerId;
        this.button = button;
        this.axis = axis;
        this.axisValue = axisValue;
    }
}
