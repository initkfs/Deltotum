module app.dm.kit.windows.window_manager;

import app.core.components.units.services.loggable_unit : LoggableUnit;
import app.dm.kit.windows.window : Window;

import std.logger : Logger;
import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class WindowManager : LoggableUnit
{
    protected
    {
        Window[] windows;
    }

    bool isAllowDuplicateId;

    this(Logger logger) pure @safe
    {
        super(logger);
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

    Nullable!Window byFirstId(long id)
    {
        Nullable!Window mustBeWindow;
        onWindowsById(id, (win) {
            mustBeWindow = Nullable!Window(win);
            return false;
        });

        return mustBeWindow;
    }

    Nullable!Window current()
    {
        Nullable!Window mustBeWindow;
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
        logger.tracef("Add window '%s' with id %d", window.title, window.id);
        return true;
    }

    bool remove(Window window)
    {
        if (windows.length == 0)
        {
            logger.tracef("Skip window removal '%s' with id %d due to missing windows", window.title, window
                    .id);
            return false;
        }

        import std.algorithm.mutation : remove;
        import std.algorithm.searching : countUntil;

        immutable ptrdiff_t removePos = windows.countUntil(window);
        if (removePos != -1)
        {
            windows = windows.remove(removePos);
            logger.tracef("Remove window '%s' with id %d", window.title, window.id);
            return true;
        }

        logger.tracef("Skip window removal '%s' with id %d: window not found in window list", window.title, window
                .id);

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
            logger.tracef("Window already disposed");
            return;
        }
        auto winId = window.id;

        auto isRemoved = remove(window);
        logger.tracef("Remove window with id '%s': %s", winId, isRemoved);

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
