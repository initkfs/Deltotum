module deltotum.platform.sdl.sdl_window;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.platform.results.platform_result : PlatformResult;
import deltotum.platform.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.toolkit.input.mouse.mouse_cursor_type : MouseCursorType;
import deltotum.platform.sdl.sdl_cursor : SDLCursor;
import deltotum.platform.sdl.sdl_surface : SdlSurface;

import std.string : toStringz, fromStringz;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlWindow : SdlObjectWrapper!SDL_Window
{

    string title;

    private
    {
        int initialWidth;
        int initialHeight;
        double initialAspectRatio = 0;
        SDLCursor lastCursor;
    }

    this(string title,
        int x, int y, int w,
        int h, uint flags = SDL_WINDOW_RESIZABLE)
    {
        super();
        this.title = title;
        this.initialWidth = w;
        this.initialHeight = h;
        initialAspectRatio = initialWidth / initialHeight;

        ptr = SDL_CreateWindow(title.toStringz,
            x, y, w,
            h, flags);
        if (ptr is null)
        {
            string msg = getError;
            throw new Exception("Unable to initialize SDL window: " ~ msg);
        }

    }

    this(SDL_Window* ptr)
    {
        super(ptr);
    }

    void focus() @nogc nothrow
    {
        SDL_RaiseWindow(ptr);
    }

    void minimize() @nogc nothrow
    {
        SDL_MinimizeWindow(ptr);
    }

    void maximize() @nogc nothrow
    {
        SDL_MaximizeWindow(ptr);
    }

    void bordered(bool isBordered) @nogc nothrow
    {
        SDL_SetWindowBordered(ptr, typeConverter.fromBool(isBordered));
    }

    void grab(bool isGrabbed) @nogc nothrow
    {
        SDL_SetWindowGrab(ptr, typeConverter.fromBool(isGrabbed));
    }

    void grabKeyboard(bool isGrabbed) @nogc nothrow
    {
        SDL_SetWindowKeyboardGrab(ptr, typeConverter.fromBool(isGrabbed));
    }

    void grabMouse(bool isGrabbed) @nogc nothrow
    {
        SDL_SetWindowMouseGrab(ptr, typeConverter.fromBool(isGrabbed));
    }

    void windowIcon(SdlSurface surface)
    {
        SDL_SetWindowIcon(ptr, surface.getObject);
    }

    void resizable(bool isResizable) @nogc nothrow
    {
        SDL_SetWindowResizable(ptr, typeConverter.fromBool(isResizable));
    }

    PlatformResult opacity(float value0to1) nothrow
    {
        if (value0to1 < 0.0 || value0to1 > 1.0)
        {
            return PlatformResult.error("Opacity value must be in the range from 0 to 1.0");
        }
        const result = SDL_SetWindowOpacity(ptr, value0to1);
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

    PlatformResult flash() nothrow
    {
        const result = SDL_FlashWindow(ptr, SDL_FlashOperation.SDL_FLASH_UNTIL_FOCUSED);
        return result != 0 ? PlatformResult(result, getError) : PlatformResult.success;
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
        SDL_Rect bounds;
        bounds.x = 0;
        bounds.y = 0;
        bounds.w = initialWidth;
        bounds.h = initialHeight;
        return bounds;
    }

    SDL_Rect getScaleBounds() @nogc nothrow
    {
        int width, height;
        getSize(&width, &height);

        SDL_Rect bounds;
        if (width > initialWidth)
        {
            const widthBar = (width - initialWidth) / 2;
            bounds.x = widthBar;
            bounds.w = width - widthBar;
        }

        if (height > initialHeight)
        {
            const heightBar = (height - initialHeight) / 2;
            bounds.y = heightBar;
            bounds.h = height - heightBar;
        }

        return bounds;
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

    void setBordered(bool value) @nogc nothrow
    {
        const SDL_bool sdlValue = typeConverter.fromBool(value);
        SDL_SetWindowBordered(ptr, sdlValue);
    }

    void show() @nogc nothrow
    {
        SDL_ShowWindow(ptr);
    }

    void hide() @nogc nothrow
    {
        SDL_HideWindow(ptr);
    }

    void setTitle(string title) nothrow
    {
        SDL_SetWindowTitle(ptr, title.toStringz);
    }

    void setResizable(bool isResizable) @nogc nothrow
    {
        SDL_bool isSdlResizable = typeConverter.fromBool(isResizable);
        SDL_SetWindowResizable(ptr, isSdlResizable);
    }

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

    //TODO move clipboard api to input
    bool clipboardHasText() @nogc nothrow
    {
        SDL_bool hasText = SDL_HasClipboardText();
        return typeConverter.toBool(hasText);
    }

    PlatformResult clipboardSetText(char* text) nothrow
    {
        const int result = SDL_SetClipboardText(text);
        if (result != 0)
        {
            return PlatformResult(result, getError);
        }
        return PlatformResult.success;
    }

    PlatformResult clipboardGetText(out string text) nothrow
    {
        char* textPtr = SDL_GetClipboardText();
        if (!textPtr)
        {
            return PlatformResult(-1, "Failed to get text from clipboard: " ~ getError);
        }
        text = textPtr.fromStringz.idup;
        SDL_free(textPtr);
        return PlatformResult.success;
    }

    override protected bool destroyPtr()
    {
        destroyCursor;

        if (ptr)
        {
            SDL_DestroyWindow(ptr);
            if (auto err = getError)
            {
                throw new Exception("Unable to destroy SDL window: " ~ err);
            }
            return true;
        }
        return false;
    }

}
