module deltotum.core.applications.components.uni.uni_component;

import deltotum.core.applications.components.units.simple_unit : SimpleUnit;
import deltotum.core.applications.components.uni.attributes : Service;
import deltotum.core.debugging.debugger : Debugger;
import deltotum.core.clis.cli : Cli;
import deltotum.core.applications.contexts.context : Context;

import std.experimental.logger.core : Logger;

/**
 * Authors: initkfs
 */
class UniComponent : SimpleUnit
{
    bool isBuilt;

    private
    {
        @Service Context _context;
        @Service Logger _logger;
        @Service Debugger _debugger;
        @Service Cli _cli;
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

    final Context context() @nogc nothrow pure @safe
    out (_context; _context !is null)
    {
        return _context;
    }

    final void context(Context context) pure @safe
    {
        import std.exception : enforce;

        enforce(context !is null, "Context must not be null");
        _context = context;

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

    final Cli cli() @nogc nothrow pure @safe
    out (_cli; _cli !is null)
    {
        return _cli;
    }

    final void cli(Cli cli) pure @safe
    {
        import std.exception : enforce;

        enforce(cli !is null, "Cli must not be null");
        _cli = cli;
    }
}
