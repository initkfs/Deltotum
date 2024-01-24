module dm.backends.sdl2.sdl_cursor;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.com.inputs.cursors.com_cursor : ComCursor, ComSystemCursorType;

import dm.backends.sdl2.base.sdl_object_wrapper : SdlObjectWrapper;
import dm.com.platforms.results.com_result : ComResult;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SDLCursor : SdlObjectWrapper!SDL_Cursor, ComCursor
{
    bool isDefault;

    this()
    {
        super();
    }

    this(SDL_Cursor* ptr)
    {
        super(ptr);
    }

    this(ComSystemCursorType type)
    {
        SDL_SystemCursor sdlType = SDL_SystemCursor.SDL_SYSTEM_CURSOR_ARROW;
        final switch (type) with (ComSystemCursorType)
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

        ptr = SDL_CreateSystemCursor(sdlType);
        if (!ptr)
        {
            import std.string : fromStringz;

            throw new Exception(getError.fromStringz.idup);
        }
    }

    ComResult fromDefaultCursor() @nogc nothrow
    {
        SDL_Cursor* cursorPtr;
        if (const err = defaultCursorPtr(cursorPtr))
        {
            return err;
        }
        ptr = cursorPtr;
        return ComResult.success;
    }

    ComResult defaultCursorPtr(out SDL_Cursor* cursorPtr) @nogc nothrow
    {
        auto mustBeCursorPtr = SDL_GetCursor();
        if (!mustBeCursorPtr)
        {
            return ComResult.error("Default cursor pointer is null");
        }
        cursorPtr = mustBeCursorPtr;
        return ComResult.success;
    }

    ComResult set() @nogc nothrow
    {
        if (!ptr)
        {
            return ComResult.error("Cursor pointer is null");
        }

        SDL_SetCursor(ptr);
        return ComResult.success;
    }

    ComResult redraw() @nogc nothrow
    {
        SDL_SetCursor(null);
        return ComResult.success;
    }

    ComResult getPos(out int x, out int y) @nogc nothrow
    {
        //const buttonMask = 
        SDL_GetMouseState(&x, &y);
        return ComResult.success;
    }

    override protected bool disposePtr() @nogc nothrow
    {
        if (ptr)
        {
            SDL_FreeCursor(ptr);
            return true;
        }
        return false;
    }
}
