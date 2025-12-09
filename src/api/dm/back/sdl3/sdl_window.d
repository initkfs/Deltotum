module api.dm.back.sdl3.sdl_window;

import api.dm.com.com_result;

import api.dm.com.graphics.com_window : ComWindowId, ComWindow, ComWindowTheme, ComWindowProgressState;
import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.com.com_result : ComResult;
import api.dm.com.graphics.com_screen : ComScreenId;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.com.inputs.com_cursor : ComCursor, ComPlatformCursorType;

import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;
import api.dm.back.sdl3.sdl_surface : SdlSurface;

import api.math.geom2.rect2 : Rect2f;

import std.string : toStringz, fromStringz;
import std.typecons : Nullable;

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

    Nullable!(SDL_Renderer*) renderer;

    protected
    {
        int initWidth;
        int initHeight;
    }

    this(int width, int height)
    {
        super();
        this.initWidth = width;
        this.initHeight = height;
    }

    this(SDL_Window* ptr)
    {
        super(ptr);
    }

    ComResult create(ComNativePtr newPtr) nothrow
    {
        assert(!ptr);
        //TODO renderer?
        ptr = newPtr.castSafe!(SDL_Window*);
        return ComResult.success;
    }

    ComResult create() nothrow => create(initWidth, initHeight, 0);

    ComResult create(int width, int height, ulong flags) nothrow
    {
        if (width < 0)
        {
            return ComResult.error("SDL window width must be positive number or 0");
        }

        if (height < 0)
        {
            return ComResult.error("SDL Window height must be positive number or 0");
        }
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

        assert(!ptr);
        assert(renderer.isNull);

        SDL_Renderer* mustBeRenderer;

        if (!SDL_CreateWindowAndRenderer(null, width, height, flags, &ptr, &mustBeRenderer))
        {
            return getErrorRes("Error creating SDL window");
        }

        assert(ptr);
        assert(mustBeRenderer);

        renderer = mustBeRenderer;

        return ComResult.success;
    }

    ComResult show() nothrow
    {
        assert(ptr);

        if (!SDL_ShowWindow(ptr))
        {
            return getErrorRes("Error showing SDL window");
        }
        return ComResult.success;
    }

    ComResult hide() nothrow
    {
        assert(ptr);

        if (!SDL_HideWindow(ptr))
        {
            return getErrorRes("Error hiding SDL window");
        }
        return ComResult.success;
    }

    ComResult close() nothrow
    {
        assert(ptr);

        dispose;
        return ComResult.success;
    }

    ComResult restore() nothrow
    {
        assert(ptr);
        // If an immediate change is required, call SDL_SyncWindow() to block until the changes have taken effect.
        //https://wiki.libsdl.org/SDL3/SDL_RestoreWindow
        if (!SDL_RestoreWindow(ptr))
        {
            return getErrorRes("Error restoring SDL window");
        }
        return ComResult.success;
    }

    ComResult setParent(ComWindow parent) nothrow
    {
        assert(ptr);
        assert(parent);

        ComNativePtr parentPtr;
        if (const err = parent.nativePtr(parentPtr))
        {
            return err;
        }
        SDL_Window* parentWinPtr = parentPtr.castSafe!(SDL_Window*);

        if (!SDL_SetWindowParent(ptr, parentWinPtr))
        {
            return getErrorRes("Error setting parent for SDL window");
        }

        return ComResult.success;
    }

    ComResult setModal(bool value) nothrow
    {
        assert(ptr);

        if (!SDL_SetWindowModal(ptr, value))
        {
            return getErrorRes("Error setting window modal value");
        }
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

    ComResult isHidden(out bool value) nothrow
    {
        ulong flags;
        if (const err = getFlags(flags))
        {
            return err;
        }

        if (flags & SDL_WINDOW_HIDDEN)
        {
            value = true;
        }
        return ComResult.success;
    }

    ComResult getId(out ComWindowId id) nothrow
    {
        assert(ptr);

        const idOrZeroError = SDL_GetWindowID(ptr);
        if (idOrZeroError == 0)
        {
            return getErrorRes("Error getting SDL window id");
        }

        id = idOrZeroError;

        return ComResult.success;
    }

    ComResult getScreenId(out ComScreenId id) nothrow
    {
        assert(ptr);

        const idOrZeroErr = SDL_GetDisplayForWindow(ptr);
        if (idOrZeroErr <= 0)
        {
            return getErrorRes("Error getting screen id from SDL window");
        }

        id = idOrZeroErr;
        return ComResult.success;
    }

    ComResult focusRequest() nothrow
    {
        assert(ptr);

        if (!SDL_RaiseWindow(ptr))
        {
            return getErrorRes("Error raising SDL window");
        }
        return ComResult.success;
    }

    ComResult getPos(out int x, out int y) nothrow
    {
        assert(ptr);

        if (!SDL_GetWindowPosition(ptr, &x, &y))
        {
            return getErrorRes("Error getting SDL window position");
        }
        return ComResult.success;
    }

    ComResult setPos(int x, int y) nothrow
    {
        assert(ptr);

        if (!SDL_SetWindowPosition(ptr, x, y))
        {
            return getErrorRes("Error setting SDL window position");
        }
        return ComResult.success;
    }

    ComResult getFlags(out ulong flags) nothrow
    {
        assert(ptr);

        flags = SDL_GetWindowFlags(ptr);
        return ComResult.success;
    }

    ComResult getMinimized(out bool value) nothrow
    {
        ulong flags;
        if (const err = getFlags(flags))
        {
            return err;
        }

        if (flags & SDL_WINDOW_MINIMIZED)
        {
            value = true;
        }

        return ComResult.success;
    }

    ComResult setMinimized() nothrow
    {
        assert(ptr);

        if (!SDL_MinimizeWindow(ptr))
        {
            return getErrorRes("Error minimize SDL window");
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

        if (flags & SDL_WINDOW_MAXIMIZED)
        {
            value = true;
        }

        return ComResult.success;
    }

    ComResult setMaximized() nothrow
    {
        assert(ptr);

        if (!SDL_MaximizeWindow(ptr))
        {
            return getErrorRes("Error maximize SDL window");
        }

        return ComResult.success;
    }

    ComResult setDecorated(bool isDecorated) nothrow
    {
        assert(ptr);

        if (!SDL_SetWindowBordered(ptr, isDecorated))
        {
            return getErrorRes("Error setting bordered SDL window");
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

    ComResult getBorderless(out bool isBorderless) nothrow
    {
        ulong flags;
        if (const err = getFlags(flags))
        {
            return err;
        }

        if (flags & SDL_WINDOW_BORDERLESS)
        {
            isBorderless = true;
        }

        return ComResult.success;
    }

    ComResult setResizable(bool isResizable) nothrow
    {
        assert(ptr);

        if (!SDL_SetWindowResizable(ptr, isResizable))
        {
            return getErrorRes("Error setting SDL window resizable");
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

        if (flags & SDL_WINDOW_RESIZABLE)
        {
            isResizable = true;
        }
        return ComResult.success;
    }

    ComResult setOpacity(float value0to1) nothrow
    {
        assert(ptr);

        if (value0to1 < 0.0 || value0to1 > 1.0)
        {
            return ComResult.error("SDL window opacity must be in the range from 0 to 1.0");
        }

        if (!SDL_SetWindowOpacity(ptr, value0to1))
        {
            return getErrorRes("Error setting SDL window opacity");
        }

        return ComResult.success;
    }

    ComResult getOpacity(out float value0to1) nothrow
    {
        assert(ptr);

        const result = SDL_GetWindowOpacity(ptr);
        if (result == -1f)
        {
            return getErrorRes("Error getting SDL window opacity");
        }

        import std.math.traits : isFinite;

        if (isFinite(result) && (result >= 0 && result <= 1.0))
        {
            value0to1 = result;
        }
        else
        {
            import std.conv : text;

            try
            {
                return getErrorRes(text("Received invalid opacity from SDL window: ", result));
            }
            catch (Exception e)
            {
                return ComResult.error(e.msg);
            }
        }

        return ComResult.success;
    }

    ComResult setFullScreen(bool isFullScreen) nothrow
    {
        assert(ptr);

        if (!SDL_SetWindowFullscreen(ptr, isFullScreen))
        {
            return getErrorRes("Error setting SDL window fullscreen");
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

        if (flags & SDL_WINDOW_FULLSCREEN)
        {
            isFullScreen = true;
        }
        return ComResult.success;
    }

    ComResult getSize(out int width, out int height) nothrow
    {
        return getRawWindowSize(&width, &height);
    }

    ComResult getWidth(out int width) nothrow
    {
        return getRawWindowSize(&width, null);
    }

    ComResult getHeight(out int height) nothrow
    {
        return getRawWindowSize(null, &height);
    }

    protected ComResult getRawWindowSize(int* width, int* height) nothrow
    {
        assert(ptr);

        if (!SDL_GetWindowSize(ptr, width, height))
        {
            return getErrorRes("Error getting SDL window size");
        }
        return ComResult.success;
    }

    ComResult setSize(int width, int height) nothrow
    {
        assert(ptr);

        if (!SDL_SetWindowSize(ptr, width, height))
        {
            return getErrorRes("Error setting SDL window size");
        }
        return ComResult.success;
    }

    ComResult getTitle(out dstring title) nothrow
    {
        assert(ptr);

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
        assert(ptr);

        import std.utf : toUTFz;

        //TODO reference
        try
        {
            const(char*) titlePtr = title.toUTFz!(const(char*));

            if (!SDL_SetWindowTitle(ptr, titlePtr))
            {
                return getErrorRes("Error setting SDL window title");
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
        assert(ptr);

        if (w <= 0)
        {
            return ComResult.error("SDL window maximum width must be positive number");
        }

        if (h <= 0)
        {
            return ComResult.error("SDL window maximum height must be positive number");
        }

        if (!SDL_SetWindowMaximumSize(ptr, w, h))
        {
            return getErrorRes("Error setting SDL window max size");
        }
        return ComResult.success;
    }

    ComResult setMinSize(int w, int h) nothrow
    {
        assert(ptr);

        if (w <= 0)
        {
            return ComResult.error("SDL window minimum width must be positive number");
        }

        if (h <= 0)
        {
            return ComResult.error("SDL window minimum height must be positive number");
        }

        if (!SDL_SetWindowMinimumSize(ptr, w, h))
        {
            return getErrorRes("Error setting SDL window minimum size");
        }
        return ComResult.success;
    }

    ComResult getSafeBounds(out Rect2f bounds) nothrow
    {
        assert(ptr);
        SDL_Rect rect;
        if (!SDL_GetWindowSafeArea(ptr, &rect))
        {
            return getErrorRes("Error getting windows safe bounds");
        }
        bounds = Rect2f(rect.x, rect.y, rect.w, rect.h);
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

    ComResult setIcon(ComSurface icon) nothrow
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
            return getErrorRes("Error setting window icon");
        }

        return ComResult.success;
    }

    ComResult setTextInputArea(Rect2f area, int cursor = 0) nothrow
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

    ComResult setTextInputStop() nothrow
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

    bool getProgress(out float value)
    {
        float newValue = SDL_GetWindowProgressValue(ptr);
        if (newValue == -1)
        {
            return false;
        }
        value = newValue;
        return true;
    }

    bool setProgress(float value0to1) => SDL_SetWindowProgressValue(ptr, value0to1);

    bool getProgressState(out ComWindowProgressState newState)
    {
        SDL_ProgressState state = SDL_GetWindowProgressState(ptr);
        ComWindowProgressState targetState;
        final switch (state) with (SDL_ProgressState)
        {
            case SDL_PROGRESS_STATE_INVALID:
                return false;
            case SDL_PROGRESS_STATE_NONE:
                targetState = ComWindowProgressState.none;
                break;
            case SDL_PROGRESS_STATE_INDETERMINATE:
                targetState = ComWindowProgressState.indeterminate;
                break;
            case SDL_PROGRESS_STATE_NORMAL:
                targetState = ComWindowProgressState.normal;
                break;
            case SDL_PROGRESS_STATE_PAUSED:
                targetState = ComWindowProgressState.paused;
                break;
            case SDL_PROGRESS_STATE_ERROR:
                targetState = ComWindowProgressState.error;
                break;
        }

        newState = targetState;
        return true;
    }

    bool setProgressState(ComWindowProgressState state)
    {
        SDL_ProgressState targetState;
        final switch (state) with (ComWindowProgressState)
        {
            case none:
                targetState = SDL_PROGRESS_STATE_NONE;
                break;
            case indeterminate:
                targetState = SDL_PROGRESS_STATE_INDETERMINATE;
                break;
            case normal:
                targetState = SDL_PROGRESS_STATE_NORMAL;
                break;
            case paused:
                targetState = SDL_PROGRESS_STATE_PAUSED;
                break;
            case error:
                targetState = SDL_PROGRESS_STATE_ERROR;
                break;
        }

        return SDL_SetWindowProgressState(ptr, targetState);
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

    void* rawPtr() nothrow
    {
        return ptr;
    }

    ComResult startTextInput()
    {
        assert(ptr);
        if (!SDL_StartTextInput(ptr))
        {
            return getErrorRes("Error starting text input");
        }
        return ComResult.success;
    }

    ComResult endTextInput()
    {
        assert(ptr);
        if (!SDL_StopTextInput(ptr))
        {
            return getErrorRes("Error stopping text input");
        }
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
