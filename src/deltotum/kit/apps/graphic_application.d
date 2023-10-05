module deltotum.kit.apps.graphic_application;

import deltotum.core.configs.config : Config;
import deltotum.core.contexts.context : Context;
import deltotum.core.apps.application_exit : ApplicationExit;
import deltotum.core.apps.cli_application : CliApplication;
import deltotum.kit.apps.comps.graphics_component : GraphicsComponent;
import deltotum.core.apps.uni.uni_component : UniComponent;
import deltotum.kit.windows.window_manager : WindowManager;
import deltotum.core.extensions.extension : Extension;
import deltotum.kit.apps.caps.cap_graphics : CapGraphics;

import deltotum.kit.windows.window : Window;
import deltotum.kit.apps.loops.loop : Loop;

import std.logger : Logger;
import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
abstract class GraphicApplication : CliApplication
{
    bool isVideoEnabled = true;
    bool isAudioEnabled;
    bool isTimerEnabled;
    bool isJoystickEnabled;
    bool isIconPackEnabled = true;

    bool isQuitOnCloseAllWindows = true;

    private
    {
        GraphicsComponent _graphicServices;
    }

    WindowManager windowManager;

    override ApplicationExit initialize(string[] args)
    {
        if (const exit = super.initialize(args))
        {
            return exit;
        }

        if (!_graphicServices)
        {
            _graphicServices = newGraphicServices;
        }

        if (!_graphicServices.hasCapGraphics)
        {
            _graphicServices.capGraphics = newCapability;
        }

        return ApplicationExit(false);
    }

    CapGraphics newCapability()
    {
        return new CapGraphics;
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

    void requestQuit()
    {
        if (uservices && uservices.logger)
        {
            uservices.logger.tracef("Request quit");
        }
    }

    void closeWindow(long id)
    {
        uservices.logger.tracef("Request close window with id '%s'", id);
        windowManager.closeWindow(id);

        if (windowManager.windowsCount == 0 && isQuitOnCloseAllWindows)
        {
            uservices.logger.tracef("All windows are closed, exit request");
            requestQuit;
        }
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
