module api.dm.kit.components.graphics_component;

import api.core.components.uni_component : UniComponent;

import api.core.components.component_service : Service;

import api.dm.kit.assets.asset : Asset;
import api.dm.kit.media.multimedia : MultiMedia;
import api.dm.kit.graphics.graphic : Graphic;
import api.dm.kit.inputs.input : Input;
import api.dm.kit.windows.window : Window;
import api.dm.kit.windows.windowing : Windowing;
import api.dm.kit.platforms.platform : Platform;
import api.dm.kit.i18n.i18n : I18n;
import api.dm.kit.windows.window : Window;
import api.dm.gui.interacts.interact : Interact;

/**
 * Authors: initkfs
 */
class GraphicsComponent : UniComponent
{
    private
    {
        @Service Graphic _graphics;
        @Service Input _input;
        @Service Platform _platform;
        @Service Asset _asset;
        @Service I18n _i18n;
        @Service Windowing _windowing;
        @Service MultiMedia _media;
    }

    alias build = UniComponent.build;
    alias buildInit = UniComponent.buildInit;
    alias buildInitCreate = UniComponent.buildInitCreate;
    alias buildInitCreateRun = UniComponent.buildInitCreateRun;

    void build(GraphicsComponent gComponent)
    {
        buildFromParent(gComponent, this);
    }

    void buildInit(GraphicsComponent component)
    {
        build(component);
        initialize(component);
    }

    void buildInitCreate(GraphicsComponent component)
    {
        buildInit(component);
        create(component);
    }

    void buildInitCreateRun(GraphicsComponent component)
    {
        buildInitCreate(component);
        run(component);
    }

    bool hasGraphics() const nothrow pure @safe
    {
        return _graphics !is null;
    }

    inout(Graphic) graphics() inout nothrow pure @safe
    out (_graphics; _graphics !is null)
    {
        return _graphics;
    }

    void graphics(Graphic graphics) pure @safe
    {
        import std.exception : enforce;

        enforce(graphics, "Graphic must not be null");
        _graphics = graphics;
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

    bool hasWindowing() const nothrow pure @safe
    {
        return _windowing !is null;
    }

    inout(Windowing) windowing() inout nothrow pure @safe
    out (_windowing; _windowing !is null)
    {
        return _windowing;
    }

    void windowing(Windowing windows) pure @safe
    {
        import std.exception : enforce;

        enforce(windows, "Windowing must not be null");
        _windowing = windows;
    }

    bool hasWindow() const nothrow pure @safe
    {
        return hasWindowing && _windowing.main !is null;
    }

    inout(Window) window() inout nothrow pure @safe
    out (_window; _window !is null)
    {
        return _windowing.main;
    }

    bool hasMedia() const nothrow pure @safe
    {
        return _media !is null;
    }

    inout(MultiMedia) media() inout nothrow pure @safe
    out (_media; _media !is null)
    {
        return _media;
    }

    void media(MultiMedia newMedia) pure @safe
    {
        import std.exception : enforce;

        enforce(newMedia, "Multimedia system must not be null");
        _media = newMedia;
    }
}
