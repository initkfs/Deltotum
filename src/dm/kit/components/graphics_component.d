module dm.kit.components.graphics_component;

import dm.core.components.uni_component : UniComponent;

import dm.core.components.attributes : Service;

import dm.kit.assets.asset : Asset;
import dm.kit.media.audio.audio : Audio;
import dm.kit.graphics.graphics : Graphics;
import dm.kit.inputs.input : Input;
import dm.kit.windows.window : Window;
import dm.kit.screens.screen : Screen;
import dm.kit.events.kit_event_manager : KitEventManager;
import dm.kit.apps.caps.cap_graphics : CapGraphics;
import dm.kit.timers.timer : Timer;
import dm.kit.platforms.platform : Platform;

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
        @Service KitEventManager _eventManager;
        @Service CapGraphics _capGraphics;
        @Service Timer _timer;
        @Service Platform _platform;
    }

    alias build = UniComponent.build;

    void build(GraphicsComponent gComponent)
    {
        buildFromParent(gComponent, this);
    }

    bool hasAsset() const nothrow pure @safe
    {
        return _asset !is null;
    }

    inout(Asset) asset() inout nothrow pure @safe
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

    bool hasInput() const nothrow pure @safe
    {
        return _input !is null;
    }

    inout(Input) input() inout nothrow pure @safe
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

    bool hasAudio() const nothrow pure @safe
    {
        return _audio !is null;
    }

    inout(Audio) audio() inout nothrow pure @safe
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

    bool hasGraphics() const nothrow pure @safe
    {
        return _graphics !is null;
    }

    inout(Graphics) graphics() inout nothrow pure @safe
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

    bool hasScreen() const nothrow pure @safe
    {
        return _screen !is null;
    }

    inout(Screen) screen() inout nothrow pure @safe
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

    bool hasEventManager() const nothrow pure @safe
    {
        return _eventManager !is null;
    }

    inout(KitEventManager) eventManager() inout nothrow pure @safe
    out (_eventManager; _eventManager !is null)
    {
        return _eventManager;
    }

    void eventManager(KitEventManager manager) pure @safe
    {
        import std.exception : enforce;

        enforce(manager !is null, "Event manager must not be null");
        _eventManager = manager;
    }

    bool hasCapGraphics() const nothrow pure @safe
    {
        return _capGraphics !is null;
    }

    inout(CapGraphics) capGraphics() inout nothrow pure @safe
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

    bool hasTimer() const nothrow pure @safe
    {
        return _timer !is null;
    }

    inout(Timer) timer() inout nothrow pure @safe
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

    bool hasPlatform() const nothrow pure @safe
    {
        return _platform !is null;
    }

    inout(Platform) platform() inout nothrow pure @safe
    out (_platform; _platform !is null)
    {
        return _platform;
    }

    void platform(Platform p) pure @safe
    {
        import std.exception : enforce;

        enforce(p !is null, "Platform must not be null");
        _platform = p;
    }
}
