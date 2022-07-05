module deltotum.application.components.uni.uni_component;

import deltotum.application.components.units.simple_unit : SimpleUnit;

import deltotum.asset.asset_manager : AssetManager;
import deltotum.window.window : Window;

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

        uniComponent.afterBuild();
    }

    public void beforeBuild()
    {

    }

    public void afterBuild()
    {

    }

    @property Logger logger() @safe pure nothrow
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

    @property AssetManager assets() @safe pure nothrow
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

    @property Window window() @safe pure nothrow
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
}
