module deltotum.kit.applications.graphic_application;

import deltotum.core.applications.application_exit : ApplicationExit;
import deltotum.core.applications.cli_application : CliApplication;
import deltotum.kit.applications.components.graphics_component : GraphicsComponent;
import deltotum.core.applications.components.uni.uni_component : UniComponent;

import deltotum.kit.window.window : Window;
import deltotum.kit.applications.loops.loop : Loop;

/**
 * Authors: initkfs
 */
abstract class GraphicApplication : CliApplication
{
    double frameRate = 60;

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
