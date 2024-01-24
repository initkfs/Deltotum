module dm.kit.windows.window_manager;

import dm.core.units.services.loggable_unit : LoggableUnit;
import dm.kit.windows.window : Window;

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

    size_t dispose(long id)
    {
        Window winForDestroy;
        size_t destroyCount;
        scope Window[] otherWindows;
        onWindowsById(id, (win) {
            if (!winForDestroy)
            {
                winForDestroy = win;
            }
            else
            {
                otherWindows ~= win;
            }
            return true;
        });

        if (winForDestroy && remove(winForDestroy))
        {
            logger.tracef("Call destroy window '%s' with id %d", winForDestroy.title, winForDestroy
                    .id);
            if(winForDestroy.isRunning){
                winForDestroy.stop;
                assert(winForDestroy.isStopped);
            }
            winForDestroy.dispose;
            destroyCount++;
        }

        if (otherWindows.length > 0)
        {
            if (!isAllowDuplicateId)
            {
                throw new Exception(
                    "Windows with duplicate IDs found");
            }

            logger.warning("Windows with duplicate IDs found");
            foreach (win; otherWindows)
            {
                if (remove(win))
                {
                    logger.tracef("Call destroy window '%s' with a duplicate id %d", win.title, win
                            .id);
                    win.dispose;
                    destroyCount++;
                }
            }
        }

        return destroyCount;
    }
}
