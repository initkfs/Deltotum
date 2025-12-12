module api.dm.kit.windows.windowing;

import api.dm.kit.windows.window : Window;

import api.core.components.units.services.loggable_unit : LoggableUnit;
import api.dm.kit.windows.window : Window;

import api.core.loggers.logging : Logging;
import std.typecons : Nullable;

/**
 * Authors: initkfs
 */

class Windowing : LoggableUnit
{
    Window main;

    protected
    {
        Window[] windows;
    }

    bool isAllowDuplicateId;

    this(Logging logging) pure @safe
    {
        super(logging);
    }

    void onWindows(scope bool delegate(Window) onWindowIsContinue)
    {
        foreach (Window window; windows)
        {
            if (!onWindowIsContinue(window))
            {
                break;
            }
        }
    }

    void onWindowsById(long id, scope bool delegate(Window) onWindowIsContinue)
    {
        onWindows((win) {
            if (win.id == id)
            {
                return onWindowIsContinue(win);
            }
            return true;
        });
    }

    Window byFirstIdOrNull(long id)
    {
        Window mustBeWindow;
        onWindowsById(id, (win) { mustBeWindow = win; return false; });

        return mustBeWindow;
    }

    Nullable!Window byFirstId(long id)
    {
        auto window = byFirstIdOrNull(id);
        if (!window)
        {
            return Nullable!Window.init;
        }

        return Nullable!Window(window);
    }

    Window currentOrNull()
    {
        Window mustBeWindow;
        onWindows((window) {
            if (window.isShowing && window.isFocus)
            {
                mustBeWindow = window;
                return false;
            }
            return true;
        });

        return mustBeWindow;
    }

    Nullable!Window current()
    {
        auto mustBeWindow = currentOrNull;
        if (!mustBeWindow)
        {
            return Nullable!Window.init;
        }

        return Nullable!Window(mustBeWindow);
    }

    bool add(Window window)
    {
        if (!isAllowDuplicateId)
        {
            bool isAlreadyExists;
            onWindows((oldWindow) {
                if (oldWindow.id == window.id)
                {
                    isAlreadyExists = true;
                    return false;
                }
                return true;
            });

            if (isAlreadyExists)
            {
                logger.tracef(
                    "Duplication is prohibited: the window '%s' is not added because already exists with id %d", window
                        .title, window
                        .id);
                return false;
            }
        }

        windows ~= window;
        version (EnableTrace)
        {
            logger.tracef("Add window '%s' with id %d", window.title, window.id);
        }
        return true;
    }

    bool remove(Window window)
    {
        if (windows.length == 0)
        {
            version (EnableTrace)
            {
                logger.tracef("Skip window removal '%s' with id %d due to missing windows", window.title, window
                        .id);
            }
            return false;
        }

        import std.algorithm.mutation : remove;
        import std.algorithm.searching : countUntil;

        immutable ptrdiff_t removePos = windows.countUntil(window);
        if (removePos != -1)
        {
            windows = windows.remove(removePos);
            version (EnableTrace)
            {
                logger.tracef("Remove window '%s' with id %d", window.title, window.id);
            }
            return true;
        }
        version (EnableTrace)
        {
            logger.tracef("Skip window removal '%s' with id %d: window not found in window list", window.title, window
                    .id);
        }

        return false;
    }

    size_t count()
    {
        return windows.length;
    }

    void destroyWindowById(long winId, bool isRemove = true)
    {
        auto mustBeWindow = byFirstId(winId);
        if (mustBeWindow.isNull)
        {
            logger.error("No window found to destroy with id ", winId);
            return;
        }
        destroyWindow(mustBeWindow.get, isRemove);
    }

    void destroyWindow(Window window, bool isRemove = true)
    {
        assert(window);
        if (window.isDisposed)
        {
            version (EnableTrace)
            {
                logger.tracef("Window already disposed");
            }
            return;
        }
        auto winId = window.id;

        auto isRemoved = remove(window);
        version (EnableTrace)
        {
            logger.tracef("Remove window with id '%s': %s", winId, isRemoved);
        }

        if (window.isRunning)
        {
            window.stop;
        }

        window.close;
    }

    void destroyAll()
    {
        foreach (Window win; windows)
        {
            destroyWindow(win, false);
        }
        windows = null;
    }
}
