module dm.back.sdl2.sdl_cursor;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.com.inputs.com_cursor : ComCursor, ComSystemCursorType;

import dm.back.sdl2.base.sdl_object_wrapper : SdlObjectWrapper;
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

    ComResult createFromType(ComSystemCursorType type) nothrow
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

        auto cursorPtr = SDL_CreateSystemCursor(sdlType);
        if (!cursorPtr)
        {
            return getErrorRes("Error creating cursor");
        }
        ptr = cursorPtr;
        return ComResult.success;
    }

    ComResult createDefault() nothrow
    {
        SDL_Cursor* cursorPtr;
        if (const err = defaultCursorPtr(cursorPtr))
        {
            return err;
        }
        ptr = cursorPtr;
        return ComResult.success;
    }

    ComResult defaultCursorPtr(out SDL_Cursor* cursorPtr) nothrow
    {
        auto mustBeCursorPtr = SDL_GetCursor();
        if (!mustBeCursorPtr)
        {
            return getErrorRes("Default cursor pointer is null");
        }
        cursorPtr = mustBeCursorPtr;
        return ComResult.success;
    }

    ComResult set() nothrow
    {
        if (!ptr)
        {
            return ComResult.error("Cursor pointer is null");
        }

        SDL_SetCursor(ptr);
        return ComResult.success;
    }

    ComResult redraw() nothrow
    {
        SDL_SetCursor(null);
        return ComResult.success;
    }

    ComResult getPos(out int x, out int y) nothrow
    {
        //const buttonMask = 
        SDL_GetMouseState(&x, &y);
        return ComResult.success;
    }

    ComResult show() nothrow
    {
        const pozitiveOrError = SDL_ShowCursor(SDL_ENABLE);
        if (pozitiveOrError < 0)
        {
            return getErrorRes(pozitiveOrError);
        }
        return ComResult.success;
    }

    ComResult hide() nothrow
    {
        const pozitiveOrError = SDL_ShowCursor(SDL_DISABLE);
        if (pozitiveOrError < 0)
        {
            return getErrorRes(pozitiveOrError);
        }
        return ComResult.success;
    }

    override protected bool disposePtr() nothrow
    {
        if (ptr)
        {
            SDL_FreeCursor(ptr);
            return true;
        }
        return false;
    }
}
