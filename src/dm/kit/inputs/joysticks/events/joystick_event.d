module dm.kit.inputs.joysticks.events.joystick_event;

import dm.core.events.event_base : EventBase;
import dm.kit.events.kit_event_type: KitEventType;
import dm.core.utils.type_util : enumNameByIndex;

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

    this(uint event, uint ownerId, int button = 0, int axis = 0, int axisValue = 0)
    {
        this.type = KitEventType.joystick;
        this.event = event;
        this.ownerId = ownerId;
        this.button = button;
        this.axis = axis;
        this.axisValue = axisValue;
    }
}
