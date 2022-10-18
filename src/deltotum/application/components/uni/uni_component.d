module deltotum.application.components.uni.uni_component;

import deltotum.application.components.units.simple_unit : SimpleUnit;

import deltotum.asset.assets : Assets;
import deltotum.window.window : Window;
import deltotum.input.input : Input;
import deltotum.audio.audio : Audio;
import deltotum.graphics.graphics : Graphics;
import deltotum.application.components.uni.attribute.attributes : service;
import deltotum.debugging.debugger : Debugger;
import std.experimental.logger.core : Logger;

/**
 * Authors: initkfs
 */
class UniComponent : SimpleUnit
{
    bool isBuilt;

    private
    {
        @service Logger _logger;
        @service Assets _assets;
        @service Window _window;
        @service Input _input;
        @service Audio _audio;
        @service Graphics _graphics;
        @service Debugger _debugger;
    }

    void build(UniComponent uniComponent)
    {
        buildFromParent(uniComponent, this);
    }

    void buildFromParent(UniComponent uniComponent, UniComponent parent)
    {

        if (uniComponent is null)
        {
            throw new Exception("Component must not be null");
        }

        if (parent is null)
        {
            throw new Exception("Parent must not be null");
        }

        uniComponent.beforeBuild();

        uniComponent.logger = parent.logger;
        uniComponent.assets = parent.assets;
        uniComponent.window = parent.window;
        uniComponent.input = parent.input;
        uniComponent.audio = parent.audio;
        uniComponent.graphics = parent.graphics;
        uniComponent.debugger = parent.debugger;

        uniComponent.afterBuild();
        uniComponent.isBuilt = true;
    }

    public void beforeBuild()
    {

    }

    public void afterBuild()
    {

    }

    @service Logger logger() @nogc @safe pure nothrow
    out (_logger; _logger !is null)
    {
        return _logger;
    }

    void logger(Logger logger) @safe pure
    {
        import std.exception : enforce;

        enforce(logger !is null, "Logger must not be null");
        _logger = logger;

    }

    @service Assets assets() @nogc @safe pure nothrow
    out (_assets; _assets !is null)
    {
        return _assets;
    }

    void assets(Assets assetManager) @safe pure
    {
        import std.exception : enforce;

        enforce(assetManager !is null, "Asset manager must not be null");
        _assets = assetManager;

    }

    @service Window window() @nogc @safe pure nothrow
    out (_window; _window !is null)
    {
        return _window;
    }

    void window(Window window) @safe pure
    {
        import std.exception : enforce;

        enforce(window !is null, "Window must not be null");
        _window = window;

    }

    @service Input input() @nogc @safe pure nothrow
    out (_input; _input !is null)
    {
        return _input;
    }

    void input(Input input) @safe pure
    {
        import std.exception : enforce;

        enforce(input !is null, "Input must not be null");
        _input = input;

    }

    @service Audio audio() @nogc @safe pure nothrow
    out (_audio; _audio !is null)
    {
        return _audio;
    }

    void audio(Audio audio) @safe pure
    {
        import std.exception : enforce;

        enforce(audio !is null, "Audio must not be null");
        _audio = audio;
    }

    @service Graphics graphics() @nogc @safe pure nothrow
    out (_graphics; _graphics !is null)
    {
        return _graphics;
    }

    void graphics(Graphics graphics) @safe pure
    {
        import std.exception : enforce;

        enforce(graphics !is null, "Graphics must not be null");
        _graphics = graphics;
    }

    @service Debugger debugger() @nogc @safe pure nothrow
    out (_debugger; _debugger !is null)
    {
        return _debugger;
    }

    void debugger(Debugger debugger) @safe pure
    {
        import std.exception : enforce;

        enforce(debugger !is null, "Debugger must not be null");
        _debugger = debugger;
    }
}
