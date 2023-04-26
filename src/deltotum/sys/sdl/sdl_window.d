module deltotum.sys.sdl.sdl_window;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.com.windows.common_window : CommonWindow;

import deltotum.com.results.platform_result : PlatformResult;
import deltotum.sys.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.kit.input.mouse.mouse_cursor_type : MouseCursorType;
import deltotum.sys.sdl.sdl_cursor : SDLCursor;
import deltotum.sys.sdl.sdl_surface : SdlSurface;

import std.string : toStringz, fromStringz;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlWindow : SdlObjectWrapper!SDL_Window, CommonWindow
{
    protected
    {
        //TODO extract
        SDLCursor lastCursor;
    }

    this()
    {
        super();
    }

    this(SDL_Window* ptr)
    {
        super(ptr);
    }

    PlatformResult initialize() @nogc nothrow
    {
        return PlatformResult.success;
    }

    PlatformResult create() nothrow
    {
        ptr = SDL_CreateWindow(
            null,
            0,
            0,
            0,
            0,
            SDL_WINDOW_HIDDEN);

        if (ptr is null)
        {
            string msg = getError;
            return PlatformResult.error("Unable to create SDL window: " ~ msg);
        }
        return PlatformResult.success;
    }

    PlatformResult obtainId(out int id) nothrow
    {
        const idOrZeroError = SDL_GetWindowID(ptr);
        if (idOrZeroError != 0)
        {
            id = idOrZeroError;
            return PlatformResult.success;
        }
        return PlatformResult(idOrZeroError, "Unable to determine window id: " ~ getError);
    }

    PlatformResult show() @nogc nothrow
    {
        SDL_ShowWindow(ptr);
        return PlatformResult.success;
    }

    PlatformResult hide() @nogc nothrow
    {
        SDL_HideWindow(ptr);
        return PlatformResult.success;
    }

    PlatformResult focusRequest() @nogc nothrow
    {
        SDL_RaiseWindow(ptr);
        return PlatformResult.success;
    }

    PlatformResult minimize() @nogc nothrow
    {
        SDL_MinimizeWindow(ptr);
        return PlatformResult.success;
    }

    PlatformResult maximize() @nogc nothrow
    {
        SDL_MaximizeWindow(ptr);
        return PlatformResult.success;
    }

    PlatformResult setDecorated(bool isDecorated) @nogc nothrow
    {
        SDL_SetWindowBordered(ptr, typeConverter.fromBool(isDecorated));
        return PlatformResult.success;
    }

    PlatformResult setResizable(bool isResizable) @nogc nothrow
    {
        SDL_bool isSdlResizable = typeConverter.fromBool(isResizable);
        SDL_SetWindowResizable(ptr, isSdlResizable);
        return PlatformResult.success;
    }

    PlatformResult setOpacity(double value0to1) nothrow
    {
        if (value0to1 < 0.0 || value0to1 > 1.0)
        {
            return PlatformResult.error("Opacity value must be in the range from 0 to 1.0");
        }
        
        const result = SDL_SetWindowOpacity(ptr, cast(float) value0to1);
        return result != 0 ? PlatformResult(result, getError) : PlatformResult.success;
    }

    PlatformResult inputFocus() nothrow
    {
        const result = SDL_SetWindowInputFocus(ptr);
        return result != 0 ? PlatformResult(result, getError) : PlatformResult.success;
    }

    PlatformResult fullscreen() nothrow
    {
        const result = SDL_SetWindowFullscreen(ptr, SDL_WINDOW_FULLSCREEN);
        return result != 0 ? PlatformResult(result, getError) : PlatformResult.success;
    }

    void getSize(int* width, int* height) @nogc nothrow
    {
        SDL_GetWindowSize(ptr, width, height);
    }

    void getPos(int* x, int* y) @nogc nothrow
    {
        SDL_GetWindowPosition(ptr, x, y);
    }

    void move(int x, int y) @nogc nothrow
    {
        SDL_SetWindowPosition(ptr, x, y);
    }

    void resize(int width, int height) @nogc nothrow
    {
        SDL_SetWindowSize(ptr, width, height);
    }

    void setTitle(string title) nothrow
    {
        SDL_SetWindowTitle(ptr, title.toStringz);
    }

    

    void maxSize(int w, int h) @nogc nothrow
    {
        SDL_SetWindowMaximumSize(ptr, w, h);
    }

    void minSize(int w, int h) @nogc nothrow
    {
        SDL_SetWindowMinimumSize(ptr, w, h);
    }

    PlatformResult modalForParent(SdlWindow parent)
    {
        const result = SDL_SetWindowModalFor(ptr, parent.getObject);
        return result != 0 ? PlatformResult(result, getError) : PlatformResult.success;
    }

    SDL_Rect getWorldBounds() @nogc nothrow
    {
        int w, h;
        getSize(&w, &h);
        SDL_Rect bounds;
        bounds.x = 0;
        bounds.y = 0;
        bounds.w = w;
        bounds.h = h;
        return bounds;
    }

    // SDL_Rect getScaleBounds() @nogc nothrow
    // {
    //     int w, h;
    //     getSize(&w, &h);

    //     SDL_Rect bounds;
    //     if (w > width)
    //     {
    //         const widthBar = (w - width) / 2;
    //         bounds.x = widthBar;
    //         bounds.w = w - widthBar;
    //     }

    //     if (h > height)
    //     {
    //         const heightBar = (h - height) / 2;
    //         bounds.y = heightBar;
    //         bounds.h = h - heightBar;
    //     }

    //     return bounds;
    // }

    void restore() @nogc nothrow
    {
        SDL_RestoreWindow(ptr);
    }

    uint getId() @nogc nothrow
    {
        return SDL_GetWindowID(ptr);
    }

    PlatformResult setCursor(MouseCursorType type)
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
            return PlatformResult(-1, getError);
        }

        destroyCursor;

        lastCursor = new SDLCursor(cursor);

        SDL_SetCursor(cursor);

        return PlatformResult(0);
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

    PlatformResult restoreCursor()
    {
        return setCursor(MouseCursorType.arrow);
    }

    void mousePos(int* x, int* y) @nogc nothrow
    {
        SDL_GetMouseState(x, y);
    }

    override protected bool destroyPtr()
    {
        destroyCursor;

        if (ptr)
        {
            SDL_DestroyWindow(ptr);
            return true;
        }
        return false;
    }

}
