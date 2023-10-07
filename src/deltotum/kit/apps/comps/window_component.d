module deltotum.kit.apps.comps.window_component;

import deltotum.kit.apps.comps.graphics_component : GraphicsComponent;
import deltotum.core.apps.uni.uni_component: UniComponent;

import deltotum.core.apps.uni.attributes : Service;

import deltotum.kit.windows.window : Window;

/**
 * Authors: initkfs
 */
class WindowComponent : GraphicsComponent
{
    private
    {
        @Service Window _window;
    }

    void build(WindowComponent wComponent)
    {
        buildFromParent(wComponent, this);
    }

    override void build(GraphicsComponent gComponent)
    {
        buildFromParent(gComponent, this);
    }

    override void build(UniComponent uniComponent)
    {
        super.build(uniComponent);
    }

    bool hasWindow() @nogc nothrow pure @safe
    {
        return _window !is null;
    }

    Window window() @nogc nothrow pure @safe
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
