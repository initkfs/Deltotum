module dm.kit.apps.comps.graphics_component;

import dm.core.units.components.uni_component : UniComponent;

import dm.core.units.components.attributes : Service;

import dm.kit.assets.asset : Asset;
import dm.kit.media.audio.audio : Audio;
import dm.kit.graphics.graphics : Graphics;
import dm.kit.inputs.input : Input;
import dm.kit.windows.window : Window;
import dm.kit.screens.screen : Screen;
import dm.kit.apps.caps.cap_graphics : CapGraphics;
import dm.kit.timers.timer : Timer;

/**
 * Authors: initkfs
 */
class GraphicsComponent : UniComponent
{
    private
    {
        @Service Audio _audio;
        @Service Asset _asset;
        @Service Graphics _graphics;
        @Service Input _input;
        @Service Screen _screen;
        @Service CapGraphics _capGraphics;
        @Service Timer _timer;
    }

    alias build = UniComponent.build;

    void build(GraphicsComponent gComponent)
    {
        buildFromParent(gComponent, this);
    }

    bool hasAsset() const @nogc nothrow pure @safe
    {
        return _asset !is null;
    }

    inout(Asset) asset() inout @nogc nothrow pure @safe
    out (_asset; _asset !is null)
    {
        return _asset;
    }

    void asset(Asset assetManager) pure @safe
    {
        import std.exception : enforce;

        enforce(assetManager !is null, "Asset manager must not be null");
        _asset = assetManager;
    }

    bool hasInput() const @nogc nothrow pure @safe
    {
        return _input !is null;
    }

    inout(Input) input() inout @nogc nothrow pure @safe
    out (_input; _input !is null)
    {
        return _input;
    }

    void input(Input input) pure @safe
    {
        import std.exception : enforce;

        enforce(input !is null, "Input must not be null");
        _input = input;
    }

    bool hasAudio() const @nogc nothrow pure @safe
    {
        return _audio !is null;
    }

    inout(Audio) audio() inout @nogc nothrow pure @safe
    out (_audio; _audio !is null)
    {
        return _audio;
    }

    void audio(Audio audio) pure @safe
    {
        import std.exception : enforce;

        enforce(audio !is null, "Audio must not be null");
        _audio = audio;
    }

    bool hasGraphics() const @nogc nothrow pure @safe
    {
        return _graphics !is null;
    }

    inout(Graphics) graphics() inout @nogc nothrow pure @safe
    out (_graphics; _graphics !is null)
    {
        return _graphics;
    }

    void graphics(Graphics graphics) pure @safe
    {
        import std.exception : enforce;

        enforce(graphics !is null, "Graphics must not be null");
        _graphics = graphics;
    }

    bool hasScreen() const @nogc nothrow pure @safe
    {
        return _screen !is null;
    }

    inout(Screen) screen() inout @nogc nothrow pure @safe
    out (_screen; _screen !is null)
    {
        return _screen;
    }

    void screen(Screen screen) pure @safe
    {
        import std.exception : enforce;

        enforce(screen !is null, "Screen must not be null");
        _screen = screen;
    }

    bool hasCapGraphics() const @nogc nothrow pure @safe
    {
        return _capGraphics !is null;
    }

    inout(CapGraphics) capGraphics() inout @nogc nothrow pure @safe
    out (_capGraphics; _capGraphics !is null)
    {
        return _capGraphics;
    }

    void capGraphics(CapGraphics caps) pure @safe
    {
        import std.exception : enforce;

        enforce(caps !is null, "Graphics capabilities must not be null");
        _capGraphics = caps;
    }

    bool hasTimer() const @nogc nothrow pure @safe
    {
        return _timer !is null;
    }

    inout(Timer) timer() inout @nogc nothrow pure @safe
    out (_timer; _timer !is null)
    {
        return _timer;
    }

    void timer(Timer t) pure @safe
    {
        import std.exception : enforce;

        enforce(t !is null, "Timer must not be null");
        _timer = t;
    }
}
