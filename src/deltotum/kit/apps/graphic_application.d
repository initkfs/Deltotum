module deltotum.kit.apps.graphic_application;

import deltotum.core.apps.application_exit : ApplicationExit;
import deltotum.core.apps.cli_application : CliApplication;
import deltotum.kit.apps.components.graphics_component : GraphicsComponent;
import deltotum.core.apps.uni.uni_component : UniComponent;
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

    bool isVectorGraphics;
    bool isQuitOnCloseAllWindows = true;

    protected
    {
        WindowManager windowManager;
        Loop mainLoop;
        GraphicsComponent _graphicServices;
    }

    this(Loop loop)
    {
        assert(loop);
        this.mainLoop = loop;
    }

    override ApplicationExit initialize(string[] args)
    {
        if (const exit = super.initialize(args))
        {
            return exit;
        }

        _graphicServices = new GraphicsComponent;

        return ApplicationExit(false);
    }

    GraphicsComponent newGraphicServices()
    {
        return new GraphicsComponent;
    }

    void build(GraphicsComponent component)
    {
        gservices.build(component);
    }

    override void build(UniComponent component)
    {
        return super.build(component);
    }

    void runLoop()
    {
        assert(mainLoop);
        mainLoop.isRunning = true;
        mainLoop.runWait;
    }

    void stopLoop(){
        assert(mainLoop);
        mainLoop.isRunning = false;
    }

    GraphicsComponent gservices() @nogc nothrow pure @safe
    out (_graphicServices; _graphicServices !is null)
    {
        return _graphicServices;
    }

    void gservices(GraphicsComponent services) pure @safe
    {
        import std.exception : enforce;

        enforce(services !is null, "Graphics services must not be null");
        _graphicServices = services;
    }
}
