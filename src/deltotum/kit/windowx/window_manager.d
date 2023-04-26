module deltotum.kit.windows.window_manager;

import deltotum.kit.windows.window : Window;

import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class WindowManager
{
    protected
    {
        Window[] windows;
    }

    void windowById(long id, bool delegate(Window) onWindowIsContinue)
    {
        foreach (Window window; windows)
        {
            if (window.id == id)
            {
                if (!onWindowIsContinue(window))
                {
                    break;
                }
            }
        }
    }

    Nullable!Window windowByFirstId(long id)
    {
        Nullable!Window mustBeWindow;
        windowById(id, (win) { mustBeWindow = Nullable!Window(win); return false; });

        return mustBeWindow;
    }

    Nullable!Window currentWindow()
    {
        foreach (window; windows)
        {
            if (window.isShowing && window.isFocus)
            {
                return Nullable!Window(window);
            }
        }

        return Nullable!Window.init;
    }

    void add(Window window)
    {
        //check id
        windows ~= window;
    }

    bool remove(Window window)
    {
        import std.algorithm.mutation : remove;
        import std.algorithm.searching : countUntil;

        immutable ptrdiff_t removePos = windows.countUntil(window);
        if (removePos != -1)
        {
            windows = windows.remove(removePos);
            return true;
        }

        return false;
    }

    void iterateWindows(bool delegate(Window) onWindowIsContinue)
    {
        foreach (Window win; windows)
        {
            if (!onWindowIsContinue(win))
            {
                break;
            }
        }
    }

    size_t windowsCount()
    {
        return windows.length;
    }

    void closeWindow(long id)
    {
        scope Window[] windowsForClose;
        windowById(id, (win) { windowsForClose ~= win; return true; });

        if (windowsForClose.length > 0)
        {
            foreach (winForClose; windowsForClose)
            {
                if (remove(winForClose))
                {
                    winForClose.destroy;
                }
            }
        }
    }
}
