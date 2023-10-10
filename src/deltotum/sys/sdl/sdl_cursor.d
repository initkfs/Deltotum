module deltotum.sys.sdl.sdl_cursor;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.sys.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.com.inputs.cursors.com_system_cursor_type : ComSystemCursorType;
import deltotum.com.platforms.results.com_result : ComResult;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SDLCursor : SdlObjectWrapper!SDL_Cursor
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

    static ComResult defaultCursor(out SDLCursor cursor)
    {
        SDL_Cursor* cursorPtr;
        if (const err = defaultCursorPtr(cursorPtr))
        {
            return err;
        }
        cursor = new SDLCursor(cursorPtr);
        return ComResult.success;
    }

    static ComResult defaultCursorPtr(out SDL_Cursor* cursorPtr)
    {
        auto mustBeCursorPtr = SDL_GetCursor();
        if (!mustBeCursorPtr)
        {
            return ComResult.error("Default cursor pointer is null");
        }
        cursorPtr = mustBeCursorPtr;
        return ComResult.success;
    }

    ComResult set()
    {
        if (!ptr)
        {
            return ComResult.error("Cursor pointer is null");
        }

        SDL_SetCursor(ptr);
        return ComResult.success;
    }

    ComResult redraw()
    {
        SDL_SetCursor(null);
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
