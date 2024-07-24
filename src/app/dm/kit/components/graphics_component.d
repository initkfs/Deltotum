module app.dm.kit.components.graphics_component;

import app.core.components.uni_component : UniComponent;

import app.core.components.attributes : Service;

import app.dm.kit.assets.asset : Asset;
import app.dm.kit.media.audio.audio : Audio;
import app.dm.kit.graphics.graphics : Graphics;
import app.dm.kit.inputs.input : Input;
import app.dm.kit.windows.window : Window;
import app.dm.kit.screens.screen : Screen;
import app.dm.kit.events.kit_event_manager : KitEventManager;
import app.dm.kit.apps.caps.cap_graphics : CapGraphics;
import app.dm.kit.platforms.platform : Platform;
import app.dm.kit.i18n.i18n: I18n;

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
        @Service Platform _platform;
        @Service I18n _i18n;
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

        enforce(assetManager, "Asset manager must not be null");
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

        enforce(input, "Input must not be null");
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

        enforce(audio, "Audio must not be null");
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

        enforce(graphics, "Graphics must not be null");
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

        enforce(screen, "Screen must not be null");
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

        enforce(manager, "Event manager must not be null");
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

        enforce(caps, "Graphics capabilities must not be null");
        _capGraphics = caps;
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

        enforce(p, "Platform must not be null");
        _platform = p;
    }

    bool hasI18n() const nothrow pure @safe
    {
        return _i18n !is null;
    }

    inout(I18n) i18n() inout nothrow pure @safe
    out (_i18n; _i18n !is null)
    {
        return _i18n;
    }

    void i18n(I18n service) pure @safe
    {
        import std.exception : enforce;

        enforce(service, "I18n must not be null");
        _i18n = service;
    }
}
