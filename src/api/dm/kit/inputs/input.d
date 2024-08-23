module api.dm.kit.inputs.input;

import api.dm.kit.inputs.cursors.cursor: Cursor;
import api.dm.kit.inputs.clipboards.clipboard : Clipboard;
import api.dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import api.dm.com.inputs.com_keyboard : ComKeyName;
import api.math.vector2 : Vector2;

import api.math.vector2 : Vector2;

import std.container.slist : SList;

/**
 * Authors: initkfs
 */
class Input
{
    SList!ComKeyName pressedKeys;

    bool justJoystickActive;
    bool justJoystickChangeAxis;
    bool justJoystickChangesAxisValue;
    double joystickAxisDelta = 0;
    bool justJoystickPressed;

    JoystickEvent lastJoystickEvent;

    Clipboard clipboard;
    Cursor systemCursor;

    this(Clipboard clipboard, Cursor cursor)
    {
        assert(clipboard);
        this.clipboard = clipboard;

        assert(cursor);
        this.systemCursor = cursor;

        pressedKeys = SList!ComKeyName();
    }

    bool addPressedKey(ComKeyName keyName)
    {
        foreach (key; pressedKeys)
        {
            if (keyName == key)
            {
                return false;
            }
        }
        pressedKeys.insertFront(keyName);
        return true;
    }

    bool addReleasedKey(ComKeyName keyName)
    {
        if (pressedKeys.front == keyName)
        {
            pressedKeys.removeFront;
            return true;
        }

        import std.algorithm.searching : find;
        import std.range : take;

        auto mustBekeyNames = find(pressedKeys[], keyName);
        if (mustBekeyNames.empty)
        {
            return false;
        }
        pressedKeys.linearRemove(take(mustBekeyNames, 1));
        return true;
    }

    bool isPressedKey(ComKeyName keyName)
    {
        foreach (key; pressedKeys)
        {
            if (key == keyName)
            {
                return true;
            }
        }

        return false;
    }

    Vector2 mousePos()
    {
        return systemCursor.getPos;
    }

    void dispose(){
        systemCursor.dispose;
        clipboard.dispose;
    }

}
