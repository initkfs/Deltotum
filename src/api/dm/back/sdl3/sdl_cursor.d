module api.dm.back.sdl3.sdl_cursor;

import api.dm.com.inputs.com_cursor : ComCursor, ComPlatformCursorType;

import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;
import api.dm.com.com_result : ComResult;
import api.dm.com.graphic.com_window : ComWindow;

import api.dm.back.sdl3.externs.csdl3;

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

    ComResult createFromType(ComPlatformCursorType type) nothrow
    {
        SDL_SystemCursor sdlType = SDL_SYSTEM_CURSOR_DEFAULT;
        final switch (type) with (ComPlatformCursorType)
        {
            case none, arrow:
                sdlType = SDL_SYSTEM_CURSOR_DEFAULT;
                break;
            case crossHair:
                sdlType = SDL_SYSTEM_CURSOR_CROSSHAIR;
                break;
            case ibeam:
                sdlType = SDL_SYSTEM_CURSOR_TEXT;
                break;
            case no:
                sdlType = SDL_SYSTEM_CURSOR_NOT_ALLOWED;
                break;
            case sizeNorthWestSouthEast:
                sdlType = SDL_SYSTEM_CURSOR_NWSE_RESIZE;
                break;
            case sizeNorthEastSouthWest:
                sdlType = SDL_SYSTEM_CURSOR_NESW_RESIZE;
                break;
            case sizeWestEast:
                sdlType = SDL_SYSTEM_CURSOR_EW_RESIZE;
                break;
            case sizeNorthSouth:
                sdlType = SDL_SYSTEM_CURSOR_NS_RESIZE;
                break;
            case sizeAll:
                sdlType = SDL_SYSTEM_CURSOR_MOVE;
                break;
            case hand:
                sdlType = SDL_SYSTEM_CURSOR_POINTER;
                break;
            case wait:
                sdlType = SDL_SYSTEM_CURSOR_WAIT;
                break;
            case waitArrow:
                sdlType = SDL_SYSTEM_CURSOR_PROGRESS;
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

    ComResult getWindowHasFocus(ComWindow buffer) nothrow
    {
        import api.dm.com.com_native_ptr : ComNativePtr;

        SDL_Window* window = SDL_GetMouseFocus();
        if (!window)
        {
            return ComResult.error("Not found window with mouse focus");
        }
        return buffer.create(ComNativePtr(window));
    }

    bool set() nothrow
    {
        if (!ptr)
        {
            return false;
        }

        if (!SDL_SetCursor(ptr))
        {
            return false;
        }

        return true;
    }

    bool redraw() nothrow
    {
        if (!SDL_SetCursor(null))
        {
            return false;
        }
        return true;
    }

    bool getPos(out float x, out float y) nothrow
    {
        //const buttonMask = 
        SDL_GetMouseState(&x, &y);
        return true;
    }

    bool show() nothrow
    {
        if (!SDL_ShowCursor())
        {
            return false;
        }
        return true;
    }

    bool hide() nothrow
    {
        if (!SDL_HideCursor())
        {
            return false;
        }
        return true;
    }

    bool isVisible() nothrow => SDL_CursorVisible;

    string getLastErrorStr() nothrow => getError;

    override protected bool disposePtr() nothrow
    {
        if (ptr)
        {
            SDL_DestroyCursor(ptr);
            return true;
        }
        return false;
    }
}
