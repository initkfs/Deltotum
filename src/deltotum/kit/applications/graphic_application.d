module deltotum.kit.applications.graphic_application;

import deltotum.core.applications.application_exit : ApplicationExit;
import deltotum.core.applications.cli_application : CliApplication;
import deltotum.kit.applications.components.graphics_component : GraphicsComponent;
import deltotum.core.applications.components.uni.uni_component : UniComponent;

import deltotum.kit.window.window : Window;
import deltotum.kit.applications.loops.loop : Loop;

import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
abstract class GraphicApplication : CliApplication
{
    double frameRate = 60;

    bool isQuitOnCloseAllWindows = true;

    protected
    {
        Window[] windows;
        Loop mainLoop;
    }

    this(Loop loop)
    {
        assert(loop);
        this.mainLoop = loop;
    }

    abstract
    {
        Window createWindow(dstring title, size_t prefWidth, size_t prefHeight, long x, long y);
    }

    void runLoop()
    {
        assert(mainLoop);
        mainLoop.isRunning = true;
        mainLoop.runWait;
    }

    override void build(UniComponent component)
    {
        return super.build(component);
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
}
