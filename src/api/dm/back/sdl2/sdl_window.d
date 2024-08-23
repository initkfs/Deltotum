module api.dm.back.sdl2.sdl_window;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.graphics.com_window : ComWindow;

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.back.sdl2.base.sdl_object_wrapper : SdlObjectWrapper;
import api.dm.com.inputs.com_cursor : ComCursor, ComSystemCursorType;

import api.dm.back.sdl2.sdl_surface : SdlSurface;

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

    ComResult initialize() nothrow
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

        //flags |= SDL_WINDOW_ALLOW_HIGHDPI;

        ptr = SDL_CreateWindow(
            null,
            0,
            0,
            0,
            0,
            flags);

        if (!ptr)
        {
            return getErrorRes("Unable to create SDL window");
        }
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
        uint flags;
        if (const err = getFlags(flags))
        {
            return err;
        }
        value = (flags & SDL_WINDOW_SHOWN) != 0;
        return ComResult.success;
    }

    ComResult show() nothrow
    {
        SDL_ShowWindow(ptr);
        return ComResult.success;
    }

    ComResult isHidden(out bool value) nothrow
    {
        uint flags;
        if (const err = getFlags(flags))
        {
            return err;
        }
        value = (flags & SDL_WINDOW_HIDDEN) != 0;
        return ComResult.success;
    }

    ComResult hide() nothrow
    {
        SDL_HideWindow(ptr);
        return ComResult.success;
    }

    ComResult close() nothrow
    {
        dispose;
        return ComResult.success;
    }

    ComResult focusRequest() nothrow
    {
        SDL_RaiseWindow(ptr);
        return ComResult.success;
    }

    ComResult getPos(out int x, out int y) nothrow
    {
        SDL_GetWindowPosition(ptr, &x, &y);
        return ComResult.success;
    }

    ComResult setPos(int x, int y) nothrow
    {
        SDL_SetWindowPosition(ptr, x, y);
        return ComResult.success;
    }

    ComResult getMinimized(out bool value) nothrow
    {
        uint flags;
        if (const err = getFlags(flags))
        {
            return err;
        }

        value = (flags & SDL_WINDOW_MINIMIZED) != 0;
        return ComResult.success;
    }

    ComResult setMinimized() nothrow
    {
        SDL_MinimizeWindow(ptr);
        return ComResult.success;
    }

    ComResult getMaximized(out bool value) nothrow
    {
        uint flags;
        if (const err = getFlags(flags))
        {
            return err;
        }

        value = (flags & SDL_WINDOW_MAXIMIZED) != 0;
        return ComResult.success;
    }

    ComResult setMaximized() nothrow
    {
        SDL_MaximizeWindow(ptr);
        return ComResult.success;
    }

    ComResult getFlags(out uint flags) nothrow
    {
        flags = SDL_GetWindowFlags(ptr);
        return ComResult.success;
    }

    ComResult getBorderless(out bool isBorderless) nothrow
    {
        uint flags;
        if (const err = getFlags(flags))
        {
            return err;
        }
        isBorderless = (flags & SDL_WINDOW_BORDERLESS) != 0;
        return ComResult.success;
    }

    ComResult setDecorated(bool isDecorated) nothrow
    {
        SDL_SetWindowBordered(ptr, typeConverter.fromBool(isDecorated));
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
        SDL_bool isSdlResizable = typeConverter.fromBool(isResizable);
        SDL_SetWindowResizable(ptr, isSdlResizable);
        return ComResult.success;
    }

    ComResult getResizable(out bool isResizable) nothrow
    {
        uint flags;
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

        const zeroOrErrorCode = SDL_SetWindowOpacity(ptr, cast(float) value0to1);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    ComResult getOpacity(out double value0to1) nothrow
    {
        float opValue;
        const zeroOrErrorCode = SDL_GetWindowOpacity(ptr, &opValue);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }

        import std.math.traits : isFinite;

        if (isFinite(opValue))
        {
            value0to1 = opValue;
        }
        else
        {
            return getErrorRes("Received non finite opacity");
        }

        return ComResult.success;
    }

    ComResult setFullScreen(bool isFullScreen) nothrow
    {
        const uint flags = isFullScreen ? SDL_WINDOW_FULLSCREEN : 0;
        const zeroOrErrorCode = SDL_SetWindowFullscreen(ptr, flags);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    ComResult getFullScreen(out bool isFullScreen) nothrow
    {
        uint flags;
        if (const err = getFlags(flags))
        {
            return err;
        }
        isFullScreen = flags & SDL_WINDOW_FULLSCREEN;
        return ComResult.success;
    }

    ComResult getSize(out int width, out int height) nothrow
    {
        SDL_GetWindowSize(ptr, &width, &height);
        return ComResult.success;
    }

    ComResult setSize(int width, int height) nothrow
    {
        SDL_SetWindowSize(ptr, width, height);
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

            SDL_SetWindowTitle(ptr, titlePtr);
        }
        catch (Exception e)
        {
            return ComResult.error(e.msg);
        }
        return ComResult.success;
    }

    ComResult setMaxSize(int w, int h) nothrow
    {
        SDL_SetWindowMaximumSize(ptr, w, h);
        return ComResult.success;
    }

    ComResult setMinSize(int w, int h) nothrow
    {
        SDL_SetWindowMinimumSize(ptr, w, h);
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

    ComResult restore() nothrow
    {
        SDL_RestoreWindow(ptr);
        return ComResult.success;
    }

    ComResult getScreenIndex(out size_t index) nothrow
    {
        const indexOrNegError = SDL_GetWindowDisplayIndex(ptr);
        if (indexOrNegError < 0)
        {
            return getErrorRes(indexOrNegError);
        }
        index = indexOrNegError;

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
        const zeroOrErrorCode = SDL_SetWindowModalFor(ptr, parentPtr);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
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
        SDL_SetWindowIcon(ptr, surfPtr);

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
