module deltotum.core.applications.components.uni.uni_component;

import deltotum.core.applications.components.units.simple_unit : SimpleUnit;

import deltotum.core.applications.components.uni.attributes : Service;

import deltotum.engine.asset.assets : Assets;
import deltotum.engine.audio.audio : Audio;
import deltotum.core.debugging.debugger : Debugger;
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
        @Service Logger _logger;
        @Service Debugger _debugger;
    }

    void build(UniComponent uniComponent)
    {
        buildFromParent(uniComponent, this);
    }

    protected void buildFromParent(C : UniComponent)(C uniComponent, C parentComponent)
    {

        if (uniComponent is null)
        {
            throw new Exception("Component must not be null");
        }

        if (parentComponent is null)
        {
            throw new Exception("Parent must not be null");
        }

        uniComponent.beforeBuild();

        import std.traits : hasUDA;
        import deltotum.core.utils.meta : hasOverloads;

        alias parentType = typeof(parentComponent);
        static foreach (const fieldName; __traits(allMembers, parentType))
        {
            static if (!hasOverloads!(parentType, fieldName) && hasUDA!(__traits(getMember, parentComponent, fieldName), Service))
            {
                __traits(getMember, uniComponent, fieldName[1 .. $]) = __traits(getMember, parentComponent, fieldName[1 .. $]);
            }
        }

        uniComponent.afterBuild();
        uniComponent.isBuilt = true;
    }

    void beforeBuild()
    {

    }

    void afterBuild()
    {

    }

    final Logger logger() @nogc nothrow pure @safe
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

    final Debugger debugger() @nogc nothrow pure @safe
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
