module deltotum.kit.inputs.input;

import deltotum.kit.inputs.clipboards.clipboard : Clipboard;
import deltotum.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import deltotum.math.vector2d : Vector2d;

import deltotum.kit.inputs.mouse.mouse_cursor_type : MouseCursorType;
import deltotum.math.vector2d : Vector2d;

import std.container.slist : SList;

//TODO move cursor and mouse
import deltotum.sys.sdl.sdl_cursor : SDLCursor;
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

    protected
    {
        //TODO remove
        SDLCursor lastCursor;
    }

    this(Clipboard clipboard)
    {
        assert(clipboard);
        this.clipboard = clipboard;

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

    Vector2d mousePos()
    {
        int x, y;
        SDL_GetMouseState(&x, &y);
        return Vector2d(x, y);
    }

    void setCursor(MouseCursorType type)
    {
        SDL_SystemCursor sdlType = SDL_SystemCursor.SDL_SYSTEM_CURSOR_ARROW;
        final switch (type) with (MouseCursorType)
        {
        case none, arrow:
            sdlType = SDL_SystemCursor.SDL_SYSTEM_CURSOR_ARROW;
            break;
        case crossHair:
            sdlType = SDL_SystemCursor.SDL_SYSTEM_CURSOR_CROSSHAIR;
            break;
        case ibeam:
            sdlType = SDL_SystemCursor.SDL_SYSTEM_CURSOR_IBEAM;
            break;
        case no:
            sdlType = SDL_SystemCursor.SDL_SYSTEM_CURSOR_NO;
            break;
        case sizeNorthWestSouthEast:
            sdlType = SDL_SystemCursor.SDL_SYSTEM_CURSOR_SIZENWSE;
            break;
        case sizeNorthEastSouthWest:
            sdlType = SDL_SystemCursor.SDL_SYSTEM_CURSOR_SIZENESW;
            break;
        case sizeWestEast:
            sdlType = SDL_SystemCursor.SDL_SYSTEM_CURSOR_SIZEWE;
            break;
        case sizeNorthSouth:
            sdlType = SDL_SystemCursor.SDL_SYSTEM_CURSOR_SIZENS;
            break;
        case sizeAll:
            sdlType = SDL_SystemCursor.SDL_SYSTEM_CURSOR_SIZEALL;
            break;
        case hand:
            sdlType = SDL_SystemCursor.SDL_SYSTEM_CURSOR_HAND;
            break;
        case wait:
            sdlType = SDL_SystemCursor.SDL_SYSTEM_CURSOR_WAIT;
            break;
        case waitArrow:
            sdlType = SDL_SystemCursor.SDL_SYSTEM_CURSOR_WAITARROW;
            break;
        }

        SDL_Cursor* cursor = SDL_CreateSystemCursor(sdlType);
        if (cursor is null)
        {
            return;
        }

        destroyCursor;

        lastCursor = new SDLCursor(cursor);

        SDL_SetCursor(cursor);
    }

    protected bool destroyCursor()
    {
        if (lastCursor !is null && !lastCursor.isDefault)
        {
            lastCursor.destroy;
            lastCursor = null;
            return true;
        }
        return false;
    }

    void restoreCursor()
    {
        return setCursor(MouseCursorType.arrow);
    }

}
