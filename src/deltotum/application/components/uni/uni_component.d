module deltotum.application.components.uni.uni_component;

import deltotum.application.components.units.simple_unit : SimpleUnit;

import deltotum.asset.asset_manager : AssetManager;
import deltotum.window.window : Window;
import deltotum.input.input : Input;
import deltotum.audio.audio : Audio;
import deltotum.graphics.graphics : Graphics;

import std.experimental.logger.core : Logger;

/**
 * Authors: initkfs
 */
class UniComponent : SimpleUnit
{
    private
    {
        Logger _logger;
        AssetManager _assets;
        Window _window;
        Input _input;
        Audio _audio;
        Graphics _graphics;
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

        uniComponent.afterBuild();
    }

    public void beforeBuild()
    {

    }

    public void afterBuild()
    {

    }

    @property Logger logger() @nogc @safe pure nothrow
    out (_logger; _logger !is null)
    {
        return _logger;
    }

    @property void logger(Logger logger) @safe pure
    {
        import std.exception : enforce;

        enforce(logger !is null, "Logger must not be null");
        _logger = logger;

    }

    @property AssetManager assets() @nogc @safe pure nothrow
    out (_assets; _assets !is null)
    {
        return _assets;
    }

    @property void assets(AssetManager assetManager) @safe pure
    {
        import std.exception : enforce;

        enforce(assetManager !is null, "Asset manager must not be null");
        _assets = assetManager;

    }

    @property Window window() @nogc @safe pure nothrow
    out (_window; _window !is null)
    {
        return _window;
    }

    @property void window(Window window) @safe pure
    {
        import std.exception : enforce;

        enforce(window !is null, "Window must not be null");
        _window = window;

    }

    @property Input input() @nogc @safe pure nothrow
    out (_input; _input !is null)
    {
        return _input;
    }

    @property void input(Input input) @safe pure
    {
        import std.exception : enforce;

        enforce(input !is null, "Input must not be null");
        _input = input;

    }

    @property Audio audio() @nogc @safe pure nothrow
    out (_audio; _audio !is null)
    {
        return _audio;
    }

    @property void audio(Audio audio) @safe pure
    {
        import std.exception : enforce;

        enforce(audio !is null, "Audio must not be null");
        _audio = audio;
    }

    @property Graphics graphics() @nogc @safe pure nothrow
    out (_graphics; _graphics !is null)
    {
        return _graphics;
    }

    @property void graphics(Graphics graphics) @safe pure
    {
        import std.exception : enforce;

        enforce(graphics !is null, "Graphics must not be null");
        _graphics = graphics;
    }
}
