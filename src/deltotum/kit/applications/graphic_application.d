module deltotum.kit.applications.graphic_application;

import deltotum.core.applications.application_exit : ApplicationExit;
import deltotum.core.applications.cli_application : CliApplication;
import deltotum.kit.applications.components.graphics_component : GraphicsComponent;
import deltotum.core.applications.components.uni.uni_component : UniComponent;
import deltotum.kit.windows.window_manager : WindowManager;

import deltotum.kit.windows.window : Window;
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
        WindowManager windowManager;
        Loop mainLoop;
    }

    this(Loop loop)
    {
        assert(loop);
        this.mainLoop = loop;
    }

    abstract
    {
        Window newWindow(dstring title, int prefWidth, int prefHeight, int x, int y);
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
}
