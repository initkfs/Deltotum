module deltotum.core.applications.components.uni.uni_component;

import deltotum.core.applications.components.units.simple_unit : SimpleUnit;

import deltotum.core.applications.components.uni.attributes : Service;

import deltotum.engine.asset.assets : Assets;
import deltotum.engine.audio.audio : Audio;
import deltotum.engine.debugging.debugger : Debugger;
import deltotum.engine.graphics.graphics : Graphics;
import std.experimental.logger.core : Logger;
import deltotum.engine.input.input : Input;
import deltotum.engine.window.window : Window;

/**
 * Authors: initkfs
 */
class UniComponent : SimpleUnit
{
    bool isBuilt;

    private
    {
        Logger _logger;
        Assets _assets;
        Window _window;
        Input _input;
        Audio _audio;
        Graphics _graphics;
        Debugger _debugger;
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

        import std.traits : hasUDA;

        alias parentType = typeof(parent);
        static foreach (const fieldName; __traits(allMembers, parentType))
        {
            static if (hasUDA!(__traits(getMember, parentType, fieldName), Service))
            {
                __traits(getMember, uniComponent, fieldName) = __traits(getMember, parent, fieldName);
            }
        }

        uniComponent.afterBuild();
        uniComponent.isBuilt = true;
    }

    public void beforeBuild()
    {

    }

    public void afterBuild()
    {

    }

    @Service final Logger logger() @nogc nothrow pure @safe
    out (_logger; _logger !is null)
    {
        return _logger;
    }

    final void logger(Logger logger) pure @safe
    {
        import std.exception : enforce;

        enforce(logger !is null, "Logger must not be null");
        _logger = logger;

    }

    @Service final Assets assets() @nogc nothrow pure @safe
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

    @Service final Window window() @nogc nothrow pure @safe
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

    @Service final Input input() @nogc nothrow pure @safe
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

    @Service final Audio audio() @nogc nothrow pure @safe
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

    @Service final Graphics graphics() @nogc nothrow pure @safe
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

    @Service final Debugger debugger() @nogc nothrow pure @safe
    out (_debugger; _debugger !is null)
    {
        return _debugger;
    }

    final void debugger(Debugger debugger) pure @safe
    {
        import std.exception : enforce;

        enforce(debugger !is null, "Debugger must not be null");
        _debugger = debugger;
    }
}