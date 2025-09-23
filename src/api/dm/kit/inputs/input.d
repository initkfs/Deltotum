module api.dm.kit.inputs.input;

import api.core.loggers.logging : Logging;

import api.dm.kit.inputs.cursors.cursor : Cursor;
import api.dm.kit.inputs.clipboards.clipboard : Clipboard;
import api.dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import api.dm.com.inputs.com_keyboard : ComKeyName;
import api.dm.kit.inputs.keyboards.keyboard : Keyboard;
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
    double joystickAxisDelta = 0;
    bool isJoystickPressed;

    JoystickEvent lastJoystickEvent;

    Clipboard clipboard;
    Cursor systemCursor;
    Keyboard keyboard;

    Logging logging;

    this(Logging logging, Keyboard keyboard, Clipboard clipboard, Cursor cursor)
    {
        assert(keyboard);
        this.keyboard = keyboard;

        assert(clipboard);
        this.clipboard = clipboard;

        assert(cursor);
        this.systemCursor = cursor;

        assert(logging);
        this.logging = logging;
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

    Vec2d pointerPos()
    {
        assert(systemCursor);

        Vec2d pos;
        if (!systemCursor.getPos(pos))
        {
            logging.logger.error("Invalid cursor position: ", systemCursor.getLastErrorStr);
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
