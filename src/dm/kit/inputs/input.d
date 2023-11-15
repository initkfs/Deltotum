module dm.kit.inputs.input;

import dm.kit.inputs.cursors.system_cursor: SystemCursor;
import dm.kit.inputs.clipboards.clipboard : Clipboard;
import dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import dm.math.vector2 : Vector2;

import dm.math.vector2 : Vector2;

import std.container.slist : SList;

//TODO remove
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Input
{
    SList!int pressedKeys;

    bool justJoystickActive;
    bool justJoystickChangeAxis;
    bool justJoystickChangesAxisValue;
    double joystickAxisDelta = 0;
    bool justJoystickPressed;

    JoystickEvent lastJoystickEvent;

    Clipboard clipboard;
    SystemCursor systemCursor;

    this(Clipboard clipboard, SystemCursor cursor)
    {
        assert(clipboard);
        this.clipboard = clipboard;

        assert(cursor);
        this.systemCursor = cursor;

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

    Vector2 mousePos()
    {
        int x, y;
        SDL_GetMouseState(&x, &y);
        return Vector2(x, y);
    }

    void dispose(){
        systemCursor.dispose;
        clipboard.dispose;
    }

}
