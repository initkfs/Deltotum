module deltotum.input.input;

import deltotum.input.joystick.event.joystick_event : JoystickEvent;

class Input
{
    @property int lastKey;
    @property bool justPressed;

    @property bool justJoystickActive;
    @property bool justJoystickChangeAxis;
    @property bool justJoystickChangesAxisValue;
    @property double joystickAxisDelta = 0;
    @property bool justJoystickPressed;
    @property int lastJoystickAxis;
    @property int lastJoystickButton;
    @property int lastJoystickAxisValue;

    bool pressed(int keyCode)
    {
        if (!justPressed)
        {
            return false;
        }

        return lastKey == keyCode;
    }
}
