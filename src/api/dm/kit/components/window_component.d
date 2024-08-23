module api.dm.kit.components.window_component;

import api.dm.kit.components.graphics_component : GraphicsComponent;
import api.core.components.uni_component: UniComponent;

import api.core.components.attributes : Service;

import api.dm.kit.windows.window : Window;

/**
 * Authors: initkfs
 */
class WindowComponent : GraphicsComponent
{
    private
    {
        @Service Window _window;
    }

    alias build = GraphicsComponent.build;
    alias build = UniComponent.build;

    void build(WindowComponent wComponent)
    {
        buildFromParent(wComponent, this);
    }

    bool hasWindow() const nothrow pure @safe
    {
        return _window !is null;
    }

    inout(Window) window() inout nothrow pure @safe
    out (_window; _window !is null)
    {
        return _window;
    }

    void window(Window window) pure @safe
    {
        import std.exception : enforce;

        enforce(window !is null, "Window must not be null");
        _window = window;
    }
}
