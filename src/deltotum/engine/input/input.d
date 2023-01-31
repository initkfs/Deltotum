module deltotum.engine.input.input;

import deltotum.engine.input.joystick.event.joystick_event : JoystickEvent;
import deltotum.core.math.vector2d : Vector2d;

import std.container.slist : SList;

class Input
{
    SList!int pressedKeys;

    bool justJoystickActive;
    bool justJoystickChangeAxis;
    bool justJoystickChangesAxisValue;
    double joystickAxisDelta = 0;
    bool justJoystickPressed;

    JoystickEvent lastJoystickEvent;

    this()
    {
        pressedKeys = SList!int();
    }

    bool addPressedKey(int keyCode)
    {
        foreach (int key; pressedKeys)
        {
            if (keyCode == key)
            {
                return false;
            }
        }
        pressedKeys.insertFront(keyCode);
        return true;
    }

    bool addReleasedKey(int keyCode)
    {
        if (pressedKeys.front == keyCode)
        {
            pressedKeys.removeFront;
            return true;
        }

        import std.algorithm.searching : find;
        import std.range : take;

        auto mustBeKeyCodes = find(pressedKeys[], keyCode);
        if (mustBeKeyCodes.empty)
        {
            return false;
        }
        pressedKeys.linearRemove(take(mustBeKeyCodes, 1));
        return true;
    }

    bool isPressedKey(int keyCode)
    {
        foreach (int key; pressedKeys)
        {
            if (key == keyCode)
            {
                return true;
            }
        }

        return false;
    }
}
