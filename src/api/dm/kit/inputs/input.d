module api.dm.kit.inputs.input;

import api.core.loggers.logging : Logging;

import api.dm.kit.inputs.cursors.cursor : Cursor;
import api.dm.kit.inputs.clipboards.clipboard : Clipboard;
import api.dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import api.dm.com.inputs.com_keyboard : ComKeyName;
import api.dm.kit.inputs.keyboards.keyboard : Keyboard;
import api.dm.com.inputs.com_joystick : ComJoystick;
import api.math.geom2.vec2 : Vec2d;

import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 */
class Input
{
    protected
    {
        //TODO best align
        bool[ComKeyName.max + 1] pressedKeys;
    }

    bool isJoystickActive;
    bool isJoystickChangeAxis;
    bool isJoystickChangeAxisValue;
    float joystickAxisDelta = 0;
    bool isJoystickPressed;

    JoystickEvent lastJoystickEvent;

    Clipboard clipboard;
    Cursor systemCursor;
    Keyboard keyboard;

    ComJoystick joystick;

    Logging logging;

    this(Logging logging, Keyboard keyboard, Clipboard clipboard, Cursor cursor, ComJoystick joystick)
    {
        assert(keyboard);
        this.keyboard = keyboard;

        assert(clipboard);
        this.clipboard = clipboard;

        assert(cursor);
        this.systemCursor = cursor;

        assert(logging);
        this.logging = logging;

        this.joystick = joystick;
    }

    protected size_t keyIndex(ComKeyName key)
    {
        return cast(size_t) key;
    }

    bool addKeyPress(ComKeyName keyName)
    {
        const ki = keyIndex(keyName);
        if (pressedKeys[ki])
        {
            return false;
        }
        pressedKeys[ki] = true;
        return true;
    }

    bool addKeyRelease(ComKeyName keyName)
    {
        const ki = keyIndex(keyName);
        if (pressedKeys[ki])
        {
            pressedKeys[ki] = false;
            return true;
        }

        return false;
    }

    bool isPressedKey(ComKeyName keyName)
    {
        const ki = keyIndex(keyName);
        return pressedKeys[ki];
    }

    bool isJoystickButton(size_t buttonIndexFrom0)
    {
        if (!joystick)
        {
            return false;
        }

        return joystick.getButton(buttonIndexFrom0);
    }

    float isJoystickAxisNorm01(size_t axisFrom0, float deadzone = 2000, float errorDelta = 0.01, float maxValue = short
            .max)
    {
        if (!joystick)
        {
            return 0;
        }

        short axisValue = isJoystickAxis(axisFrom0);

        if (axisValue == 0 || (axisValue > -deadzone && axisValue < deadzone))
        {
            return 0;
        }

        float normalizedValue = 0;
        if (axisValue > 0)
        {
            normalizedValue = cast(float)(axisValue - deadzone) / (maxValue - deadzone);
            if (normalizedValue < errorDelta)
            {
                return 0;
            }
        }
        else
        {
            normalizedValue = cast(float)(axisValue + deadzone) / (maxValue - deadzone);
            if ((-normalizedValue) < errorDelta)
            {
                return 0;
            }
        }

        return normalizedValue;
    }

    short isJoystickAxis(size_t axisFrom0)
    {
        if (!joystick)
        {
            return 0;
        }

        return joystick.getAxisOr0(axisFrom0);
    }

    Vec2d pointerPos()
    {
        assert(systemCursor);

        Vec2d pos;
        if (!systemCursor.getPos(pos))
        {
            logging.logger.error("Invalid cursor position: ", systemCursor.getLastErrorNew);
            return Vec2d.init;
        }
        return pos;
    }

    bool startTextInput()
    {
        return true;
    }

    bool endTextInput()
    {
        return true;
    }

    void dispose()
    {
        if (systemCursor)
        {
            systemCursor.dispose;
        }

        if (clipboard)
        {
            clipboard.dispose;
        }
    }

}
