module deltotum.kit.apps.components.graphics_component;

import deltotum.core.apps.uni.uni_component : UniComponent;

import deltotum.core.apps.uni.attributes : Service;

import deltotum.kit.assets.asset : Asset;
import deltotum.media.audio.audio : Audio;
import deltotum.kit.graphics.graphics : Graphics;
import deltotum.kit.inputs.input : Input;
import deltotum.kit.windows.window : Window;
import deltotum.kit.screens.screen : Screen;
import deltotum.kit.extensions.extension : Extension;
import deltotum.kit.apps.capabilities.capability : Capability;

/**
 * Authors: initkfs
 */
class GraphicsComponent : UniComponent
{
    private
    {
        @Service Audio _audio;
        @Service Asset _asset;
        @Service Extension _ext;
        @Service Graphics _graphics;
        @Service Input _input;
        @Service Screen _screen;
        @Service Window _window;
        @Service Capability _cap;
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

    final bool hasAsset() @nogc nothrow pure @safe
    {
        return _asset !is null;
    }

    final Asset asset() @nogc nothrow pure @safe
    out (_asset; _asset !is null)
    {
        return _asset;
    }

    final void asset(Asset assetManager) pure @safe
    {
        import std.exception : enforce;

        enforce(assetManager !is null, "Asset manager must not be null");
        _asset = assetManager;

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

    final bool hasScreen() @nogc nothrow pure @safe
    {
        return _screen !is null;
    }

    final Screen screen() @nogc nothrow pure @safe
    out (_screen; _screen !is null)
    {
        return _screen;
    }

    final void screen(Screen screen) pure @safe
    {
        import std.exception : enforce;

        enforce(screen !is null, "Screen must not be null");
        _screen = screen;
    }

    final bool hasExtension() @nogc nothrow pure @safe
    {
        return _ext !is null;
    }

    final Extension ext() @nogc nothrow pure @safe
    out (_ext; _ext !is null)
    {
        return _ext;
    }

    final void ext(Extension ext) pure @safe
    {
        import std.exception : enforce;

        enforce(ext !is null, "Extension must not be null");
        _ext = ext;
    }

    final bool hasCap() @nogc nothrow pure @safe
    {
        return _cap !is null;
    }

    final Capability cap() @nogc nothrow pure @safe
    out (_cap; _cap !is null)
    {
        return _cap;
    }

    final void cap(Capability caps) pure @safe
    {
        import std.exception : enforce;

        enforce(caps !is null, "Capabilities must not be null");
        _cap = caps;
    }
}
