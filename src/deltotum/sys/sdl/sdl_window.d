module deltotum.sys.sdl.sdl_window;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.com.gui.com_window : ComWindow;

import deltotum.com.platforms.results.com_result : ComResult;
import deltotum.sys.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.com.inputs.cursors.com_system_cursor_type : ComSystemCursorType;

import deltotum.sys.sdl.sdl_surface : SdlSurface;

import std.string : toStringz, fromStringz;

import bindbc.sdl;

enum SdlWindowMode
{
    none,
    opengl,
    vulkan,
}

/**
 * Authors: initkfs
 */
class SdlWindow : SdlObjectWrapper!SDL_Window, ComWindow
{
    SdlWindowMode mode;

    this()
    {
        super();
    }

    this(SDL_Window* ptr)
    {
        super(ptr);
    }

    ComResult initialize() @nogc nothrow
    {
        return ComResult.success;
    }

    ComResult create() nothrow
    {
        uint flags = SDL_WINDOW_HIDDEN;
        final switch (mode) with (SdlWindowMode)
        {
        case opengl:
            flags |= SDL_WINDOW_OPENGL;
            break;
        case vulkan:
            flags |= SDL_WINDOW_VULKAN;
            break;
        case none:
            break;
        }
        ptr = SDL_CreateWindow(
            null,
            0,
            0,
            0,
            0,
            flags);

        if (ptr is null)
        {
            const msg = getError;
            return ComResult.error("Unable to create SDL window: " ~ msg);
        }
        return ComResult.success;
    }

    ComResult obtainId(out int id) nothrow
    {
        const idOrZeroError = SDL_GetWindowID(ptr);
        if (idOrZeroError != 0)
        {
            id = idOrZeroError;
            return ComResult.success;
        }
        return ComResult(idOrZeroError, getError);
    }

    ComResult show() @nogc nothrow
    {
        SDL_ShowWindow(ptr);
        return ComResult.success;
    }

    ComResult hide() @nogc nothrow
    {
        SDL_HideWindow(ptr);
        return ComResult.success;
    }

    ComResult close() @nogc nothrow
    {
        destroy;
        return ComResult.success;
    }

    ComResult focusRequest() @nogc nothrow
    {
        SDL_RaiseWindow(ptr);
        return ComResult.success;
    }

    ComResult getPos(out int x, out int y) @nogc nothrow
    {
        SDL_GetWindowPosition(ptr, &x, &y);
        return ComResult.success;
    }

    ComResult setPos(int x, int y) @nogc nothrow
    {
        SDL_SetWindowPosition(ptr, x, y);
        return ComResult.success;
    }

    ComResult minimize() @nogc nothrow
    {
        SDL_MinimizeWindow(ptr);
        return ComResult.success;
    }

    ComResult maximize() @nogc nothrow
    {
        SDL_MaximizeWindow(ptr);
        return ComResult.success;
    }

    ComResult setDecorated(bool isDecorated) @nogc nothrow
    {
        SDL_SetWindowBordered(ptr, typeConverter.fromBool(isDecorated));
        return ComResult.success;
    }

    ComResult setResizable(bool isResizable) @nogc nothrow
    {
        SDL_bool isSdlResizable = typeConverter.fromBool(isResizable);
        SDL_SetWindowResizable(ptr, isSdlResizable);
        return ComResult.success;
    }

    ComResult setOpacity(double value0to1) @nogc nothrow
    {
        if (value0to1 < 0.0 || value0to1 > 1.0)
        {
            return ComResult.error("Opacity value must be in the range from 0 to 1.0");
        }

        const result = SDL_SetWindowOpacity(ptr, cast(float) value0to1);
        return result != 0 ? ComResult(result, getError) : ComResult.success;
    }

    ComResult setFullScreen(bool isFullScreen) @nogc nothrow
    {
        const uint flags = isFullScreen ? SDL_WINDOW_FULLSCREEN : 0;
        const result = SDL_SetWindowFullscreen(ptr, flags);
        return result != 0 ? ComResult(result, getError) : ComResult.success;
    }

    ComResult getSize(out int width, out int height) @nogc nothrow
    {
        SDL_GetWindowSize(ptr, &width, &height);
        return ComResult.success;
    }

    ComResult setSize(int width, int height) @nogc nothrow
    {
        SDL_SetWindowSize(ptr, width, height);
        return ComResult.success;
    }

    ComResult getTitle(ref const(char)[] title) @nogc nothrow
    {
        import std.string : fromStringz;

        //UTF-8
        title = SDL_GetWindowTitle(ptr).fromStringz;
        return ComResult.success;
    }

    ComResult setTitle(const(char)* title) @nogc nothrow
    {
        import std.string : toStringz;

        SDL_SetWindowTitle(ptr, title);
        return ComResult.success;
    }

    ComResult setMaxSize(int w, int h) @nogc nothrow
    {
        SDL_SetWindowMaximumSize(ptr, w, h);
        return ComResult.success;
    }

    ComResult setMinSize(int w, int h) @nogc nothrow
    {
        SDL_SetWindowMinimumSize(ptr, w, h);
        return ComResult.success;
    }

    // ComResult modalForParent(SdlWindow parent)
    // {
    //     const result = SDL_SetWindowModalFor(ptr, parent.getObject);
    //     return result != 0 ? ComResult(result, getError) : ComResult.success;
    // }

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

    ComResult restore() @nogc nothrow
    {
        SDL_RestoreWindow(ptr);
        return ComResult.success;
    }

    ComResult getScreenIndex(out size_t index) @nogc nothrow
    {
        const indexOrNegError = SDL_GetWindowDisplayIndex(ptr);
        if (indexOrNegError < 0)
        {
            return ComResult.error(getError);
        }
        index = indexOrNegError;

        return ComResult.success;
    }

    ComResult nativePtr(out void* ptr) @nogc nothrow
    {
        if (!ptr && isDestroyed)
        {
            return ComResult.error("Native window pointer is destroyed or null");
        }
        ptr = cast(void*) this.ptr;
        return ComResult.success;
    }

    override protected bool destroyPtr()
    {
        if (ptr)
        {
            SDL_DestroyWindow(ptr);
            return true;
        }
        return false;
    }

}
