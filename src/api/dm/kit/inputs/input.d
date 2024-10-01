module api.dm.kit.inputs.input;

import api.dm.kit.inputs.cursors.cursor : Cursor;
import api.dm.kit.inputs.clipboards.clipboard : Clipboard;
import api.dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import api.dm.com.inputs.com_keyboard : ComKeyName;
import api.math.vector2 : Vector2;

import api.math.vector2 : Vector2;

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

    this(Clipboard clipboard, Cursor cursor)
    {
        assert(clipboard);
        this.clipboard = clipboard;

        assert(cursor);
        this.systemCursor = cursor;
    }

    protected size_t keyIndex(ComKeyName key)
    {
        return cast(size_t) key;
    }

    bool addPressedKey(ComKeyName keyName)
    {
        const ki = keyIndex(keyName);
        if (pressedKeys[ki])
        {
            return false;
        }
        pressedKeys[ki] = true;
        return true;
    }

    bool addReleasedKey(ComKeyName keyName)
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

    Vector2 pointerPos()
    {
        return systemCursor.getPos;
    }

    void dispose()
    {
        systemCursor.dispose;
        clipboard.dispose;
    }

}
