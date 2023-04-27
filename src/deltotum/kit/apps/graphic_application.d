module deltotum.kit.apps.graphic_application;

import deltotum.core.apps.application_exit : ApplicationExit;
import deltotum.core.apps.cli_application : CliApplication;
import deltotum.kit.apps.components.graphics_component : GraphicsComponent;
import deltotum.core.apps.components.uni.uni_component : UniComponent;
import deltotum.kit.windows.window_manager : WindowManager;

import deltotum.kit.windows.window : Window;
import deltotum.kit.apps.loops.loop : Loop;

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
