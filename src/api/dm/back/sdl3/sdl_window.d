module api.dm.back.sdl3.sdl_window;

import api.dm.com.platforms.results.com_result;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.graphics.com_window : ComWindow, ComWindowTheme;

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;
import api.dm.com.inputs.com_cursor : ComCursor, ComPlatformCursorType;
import api.dm.com.graphics.com_screen : ComScreenId;

import api.dm.back.sdl3.sdl_surface : SdlSurface;

import api.math.geom2.rect2 : Rect2d;

import std.string : toStringz, fromStringz;

import api.dm.back.sdl3.externs.csdl3;

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

    SDL_Renderer* renderer;

    this()
    {
        super();
    }

    this(SDL_Window* ptr)
    {
        super(ptr);
    }

    ComResult initialize() nothrow
    {
        return ComResult.success;
    }

    ComResult create(ComNativePtr newPtr) nothrow
    {
        if (ptr)
        {
            disposePtr;
        }
        ptr = newPtr.castSafe!(SDL_Window*);
        return ComResult.success;
    }

    ComResult create() nothrow
    {
        ulong flags = SDL_WINDOW_HIDDEN;
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

        if (!SDL_CreateWindowAndRenderer(null, 0, 0, flags, &ptr, &renderer))
        {
            return getErrorRes("Unable to create SDL window");
        }

        assert(ptr);
        assert(renderer);

        return ComResult.success;
    }

    ComResult getId(out int id) nothrow
    {
        const idOrZeroError = SDL_GetWindowID(ptr);
        if (idOrZeroError == 0)
        {
            return getErrorRes("Error getting window id");
        }

        id = idOrZeroError;

        return ComResult.success;
    }

    ComResult isShown(out bool value) nothrow
    {
        bool hidden;
        if (const err = isHidden(hidden))
        {
            return err;
        }
        value = !hidden;
        return ComResult.success;
    }

    ComResult show() nothrow
    {
        if (!SDL_ShowWindow(ptr))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult isHidden(out bool value) nothrow
    {
        ulong flags;
        if (const err = getFlags(flags))
        {
            return err;
        }
        value = (flags & SDL_WINDOW_HIDDEN) != 0;
        return ComResult.success;
    }

    ComResult hide() nothrow
    {
        if (!SDL_HideWindow(ptr))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult close() nothrow
    {
        dispose;
        return ComResult.success;
    }

    ComResult focusRequest() nothrow
    {
        if (!SDL_RaiseWindow(ptr))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getPos(out int x, out int y) nothrow
    {
        if (!SDL_GetWindowPosition(ptr, &x, &y))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult setPos(int x, int y) nothrow
    {
        if (!SDL_SetWindowPosition(ptr, x, y))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getMinimized(out bool value) nothrow
    {
        ulong flags;
        if (const err = getFlags(flags))
        {
            return err;
        }

        value = (flags & SDL_WINDOW_MINIMIZED) != 0;
        return ComResult.success;
    }

    ComResult setMinimized() nothrow
    {
        if (!SDL_MinimizeWindow(ptr))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getMaximized(out bool value) nothrow
    {
        ulong flags;
        if (const err = getFlags(flags))
        {
            return err;
        }

        value = (flags & SDL_WINDOW_MAXIMIZED) != 0;
        return ComResult.success;
    }

    ComResult setMaximized() nothrow
    {
        if (!SDL_MaximizeWindow(ptr))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getFlags(out ulong flags) nothrow
    {
        flags = SDL_GetWindowFlags(ptr);
        return ComResult.success;
    }

    ComResult getBorderless(out bool isBorderless) nothrow
    {
        ulong flags;
        if (const err = getFlags(flags))
        {
            return err;
        }
        isBorderless = (flags & SDL_WINDOW_BORDERLESS) != 0;
        return ComResult.success;
    }

    ComResult setDecorated(bool isDecorated) nothrow
    {
        if (!SDL_SetWindowBordered(ptr, isDecorated))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getDecorated(out bool isDecorated) nothrow
    {
        bool isBorderless;
        if (const err = getBorderless(isBorderless))
        {
            return err;
        }
        isDecorated = !isBorderless;
        return ComResult.success;
    }

    ComResult setResizable(bool isResizable) nothrow
    {
        if (!SDL_SetWindowResizable(ptr, isResizable))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getResizable(out bool isResizable) nothrow
    {
        ulong flags;
        if (const err = getFlags(flags))
        {
            return err;
        }
        isResizable = (flags & SDL_WINDOW_RESIZABLE) != 0;
        return ComResult.success;
    }

    ComResult setOpacity(double value0to1) nothrow
    {
        if (value0to1 < 0.0 || value0to1 > 1.0)
        {
            return ComResult.error("Opacity value must be in the range from 0 to 1.0");
        }

        if (!SDL_SetWindowOpacity(ptr, cast(float) value0to1))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getOpacity(out double value0to1) nothrow
    {
        const result = SDL_GetWindowOpacity(ptr);
        if (result == -1f)
        {
            return getErrorRes;
        }

        import std.math.traits : isFinite;

        if (isFinite(result) && (result >= 0 && result <= 1.0))
        {
            value0to1 = result;
        }
        else
        {
            return getErrorRes("Received invalid opacity");
        }

        return ComResult.success;
    }

    ComResult setFullScreen(bool isFullScreen) nothrow
    {
        if (!SDL_SetWindowFullscreen(ptr, isFullScreen))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getFullScreen(out bool isFullScreen) nothrow
    {
        ulong flags;
        if (const err = getFlags(flags))
        {
            return err;
        }
        isFullScreen = flags & SDL_WINDOW_FULLSCREEN;
        return ComResult.success;
    }

    ComResult getSize(out int width, out int height) nothrow
    {
        if (!SDL_GetWindowSize(ptr, &width, &height))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult setSize(int width, int height) nothrow
    {
        if (!SDL_SetWindowSize(ptr, width, height))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getTitle(out dstring title) nothrow
    {
        import std.conv : to;

        //UTF-8
        try
        {
            title = SDL_GetWindowTitle(ptr).to!dstring;
        }
        catch (Exception e)
        {
            return ComResult.error(e.msg);
        }
        return ComResult.success;
    }

    ComResult setTitle(const(dchar[]) title) nothrow
    {
        import std.utf : toUTFz;

        //TODO reference
        try
        {
            const(char*) titlePtr = title.toUTFz!(const(char*));

            if (!SDL_SetWindowTitle(ptr, titlePtr))
            {
                return getErrorRes;
            }
        }
        catch (Exception e)
        {
            return ComResult.error(e.msg);
        }
        return ComResult.success;
    }

    ComResult setMaxSize(int w, int h) nothrow
    {
        if (!SDL_SetWindowMaximumSize(ptr, w, h))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult setMinSize(int w, int h) nothrow
    {
        if (!SDL_SetWindowMinimumSize(ptr, w, h))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    // ComResult modalForParent(SdlWindow parent)
    // {
    //     const result = SDL_SetWindowModalFor(ptr, parent.getObject);
    //     return result != 0 ? ComResult(result, getError) : ComResult.success;
    // }

    // SDL_Rect getScaleBounds()nothrow
    // {
    //     int w, h;
    //     getSize(&w, &h);

    //     SDL_Rect bounds;
    //     if (w > width)
    //     {
    //         const widthBar = (w - width) / 2;
    //         boundsRect.x = widthBar;
    //         boundsRect.w = w - widthBar;
    //     }

    //     if (h > height)
    //     {
    //         const heightBar = (h - height) / 2;
    //         boundsRect.y = heightBar;
    //         boundsRect.h = h - heightBar;
    //     }

    //     return bounds;
    // }

    ComResult restore() nothrow
    {
        // If an immediate change is required, call SDL_SyncWindow() to block until the changes have taken effect.
        //https://wiki.libsdl.org/SDL3/SDL_RestoreWindow
        if (!SDL_RestoreWindow(ptr))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getSafeBounds(out Rect2d bounds) nothrow
    {
        assert(ptr);
        SDL_Rect rect;
        if (!SDL_GetWindowSafeArea(ptr, &rect))
        {
            return getErrorRes("Error getting windows safe bounds");
        }
        bounds = Rect2d(rect.x, rect.y, rect.w, rect.h);
        return ComResult.success;
    }

    ComResult getSystemTheme(out ComWindowTheme theme) nothrow
    {
        SDL_SystemTheme currentTheme = SDL_GetSystemTheme;
        final switch (currentTheme) with (SDL_SystemTheme)
        {
            case SDL_SYSTEM_THEME_UNKNOWN:
                theme = ComWindowTheme.none;
                break;
            case SDL_SYSTEM_THEME_LIGHT:
                theme = ComWindowTheme.light;
                break;
            case SDL_SYSTEM_THEME_DARK:
                theme = ComWindowTheme.dark;
                break;
        }
        return ComResult.success;
    }

    ComResult getScreenId(out ComScreenId id) nothrow
    {
        const idOrZeroErr = SDL_GetDisplayForWindow(ptr);
        if (idOrZeroErr <= 0)
        {
            return getErrorRes("Error getting screen id for window");
        }

        id = idOrZeroErr;
        return ComResult.success;
    }

    ComResult setModalFor(ComWindow parent)
    {
        assert(parent);
        ComNativePtr nPtr;
        if (const err = parent.nativePtr(nPtr))
        {
            return err;
        }
        auto parentPtr = nPtr.castSafe!(SDL_Window*);

        if (!SDL_SetWindowParent(ptr, parentPtr))
        {
            return getErrorRes;
        }

        //TODO ptr or parentPtr?
        if (!SDL_SetWindowModal(ptr, true))
        {
            return getErrorRes;
        }

        return ComResult.success;
    }

    ComResult setIcon(ComSurface icon)
    {
        assert(icon);

        ComNativePtr nPtr;
        if (const err = icon.nativePtr(nPtr))
        {
            return err;
        }
        SDL_Surface* surfPtr = nPtr.castSafe!(SDL_Surface*);
        if (!SDL_SetWindowIcon(ptr, surfPtr))
        {
            return getErrorRes;
        }

        return ComResult.success;
    }

    ComResult setTextInputArea(Rect2d area, int cursor = 0) nothrow
    {
        assert(ptr);

        SDL_Rect rect = {
            cast(int) area.x, cast(int) area.y, cast(int) area.width, cast(int) area.height
        };

        if (!SDL_SetTextInputArea(ptr, &rect, cursor))
        {
            return getErrorRes("Cannot set text input text area");
        }
        return ComResult.success;
    }

    ComResult getIsTextInputActive(out bool isActive) nothrow
    {
        assert(ptr);
        isActive = SDL_TextInputActive(ptr);
        return ComResult.success;
    }

    ComResult setTextInputStart() nothrow
    {
        assert(ptr);
        if (!SDL_StartTextInput(ptr))
        {
            return getErrorRes("Cannot start text input for window");
        }
        return ComResult.success;
    }

    ComResult setTextInputStop()
    {
        assert(ptr);
        if (!SDL_StopTextInput(ptr))
        {
            return getErrorRes("Cannot stop text input for window");
        }
        return ComResult.success;
    }

    ComResult getDPI(out float dpi, float factor = 96) nothrow
    {
        //SDL_GetDisplayDPI() - not reliable across platforms, approximately replaced by multiplying SDL_GetWindowDisplayScale() times 160 on iPhone and Android, and 96 on other platforms.

        float scale = SDL_GetWindowDisplayScale(ptr);
        if (scale == 0)
        {
            return getErrorRes;
        }

        dpi = factor * scale;

        return ComResult.success;
    }

    ComResult nativePtr(out ComNativePtr ptrInfo) nothrow
    {
        if (!ptr && isDisposed)
        {
            return ComResult.error("Native window pointer is destroyed or null");
        }

        ptrInfo = ComNativePtr(ptr);
        return ComResult.success;
    }

    override protected bool disposePtr()
    {
        if (ptr)
        {
            SDL_DestroyWindow(ptr);
            return true;
        }
        return false;
    }

}
