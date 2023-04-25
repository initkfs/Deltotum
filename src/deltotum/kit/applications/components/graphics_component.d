module deltotum.kit.applications.components.graphics_component;

import deltotum.core.applications.components.uni.uni_component : UniComponent;

import deltotum.core.applications.components.uni.attributes : Service;

import deltotum.kit.asset.assets : Assets;
import deltotum.media.audio.audio : Audio;
import deltotum.kit.graphics.graphics : Graphics;
import deltotum.kit.input.input : Input;
import deltotum.kit.window.window : Window;

/**
 * Authors: initkfs
 */
class GraphicsComponent : UniComponent
{
    private
    {
        @Service Audio _audio;
        @Service Assets _assets;
        @Service Input _input;
        @Service Graphics _graphics;
        @Service Window _window;
    }

    //bypass hijacking
    override void build(UniComponent uniComponent)
    {
        if (auto graphicComponent = cast(GraphicsComponent) uniComponent)
        {
            buildFromParent!GraphicsComponent(graphicComponent, this);
            return;
        }
        buildFromParent(uniComponent, this);
    }

    final bool hasAssets() @nogc nothrow pure @safe
    {
        return _assets !is null;
    }

    final Assets assets() @nogc nothrow pure @safe
    out (_assets; _assets !is null)
    {
        return _assets;
    }

    final void assets(Assets assetManager) pure @safe
    {
        import std.exception : enforce;

        enforce(assetManager !is null, "Asset manager must not be null");
        _assets = assetManager;

    }

    final bool hasWindow() @nogc nothrow pure @safe
    {
        return _window !is null;
    }

    final Window window() @nogc nothrow pure @safe
    out (_window; _window !is null)
    {
        return _window;
    }

    final void window(Window window) pure @safe
    {
        import std.exception : enforce;

        enforce(window !is null, "Window must not be null");
        _window = window;

    }

    final bool hasInput() @nogc nothrow pure @safe
    {
        return _input !is null;
    }

    final Input input() @nogc nothrow pure @safe
    out (_input; _input !is null)
    {
        return _input;
    }

    final void input(Input input) pure @safe
    {
        import std.exception : enforce;

        enforce(input !is null, "Input must not be null");
        _input = input;

    }

    final bool hasAudio() @nogc nothrow pure @safe
    {
        return _audio !is null;
    }

    final Audio audio() @nogc nothrow pure @safe
    out (_audio; _audio !is null)
    {
        return _audio;
    }

    final void audio(Audio audio) pure @safe
    {
        import std.exception : enforce;

        enforce(audio !is null, "Audio must not be null");
        _audio = audio;
    }

    final bool hasGraphics() @nogc nothrow pure @safe
    {
        return _graphics !is null;
    }

    final Graphics graphics() @nogc nothrow pure @safe
    out (_graphics; _graphics !is null)
    {
        return _graphics;
    }

    final void graphics(Graphics graphics) pure @safe
    {
        import std.exception : enforce;

        enforce(graphics !is null, "Graphics must not be null");
        _graphics = graphics;
    }
}
