module app.dm.kit.inputs.input;

import app.dm.kit.inputs.cursors.cursor: Cursor;
import app.dm.kit.inputs.clipboards.clipboard : Clipboard;
import app.dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import app.dm.com.inputs.com_keyboard : ComKeyName;
import app.dm.math.vector2 : Vector2;

import app.dm.math.vector2 : Vector2;

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
