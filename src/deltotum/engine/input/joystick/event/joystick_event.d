module deltotum.engine.input.joystick.event.joystick_event;

import deltotum.engine.events.event_base : EventBase;
import deltotum.engine.events.event_type : EventType;
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

    this(EventType type, uint event, uint windowId, int button = 0, int axis = 0, int axisValue = 0)
    {
        this.type = type;
        this.event = event;
        this.windowId = windowId;
        this.button = button;
        this.axis = axis;
        this.axisValue = axisValue;
    }
}
