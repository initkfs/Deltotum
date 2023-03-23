module deltotum.core.applications.components.uni.uni_component;

import deltotum.core.applications.components.units.simple_unit : SimpleUnit;
import deltotum.core.applications.components.uni.attributes : Service;
import deltotum.core.configs.config : Config;
import deltotum.core.supports.support : Support;
import deltotum.core.clis.cli : Cli;
import deltotum.core.contexts.context : Context;
import deltotum.core.resources.resource : Resource;

import std.logger.core : Logger;

/**
 * Authors: initkfs
 */
class UniComponent : SimpleUnit
{
    bool isBuilt;
    bool callAfterBuild = true;
    bool callBeforeBuild = true;

    private
    {
        @Service Context _context;
        @Service Logger _logger;
        @Service Config _config;
        @Service Cli _cli;
        @Service Support _support;
        @Service Resource _resource;
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

        if (callBeforeBuild)
        {
            uniComponent.beforeBuild();
        }

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

        if (callAfterBuild)
        {
            uniComponent.afterBuild();
        }

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

    final Config config() @nogc nothrow pure @safe
    out (_config; _config !is null)
    {
        return _config;
    }

    final void config(Config config) pure @safe
    {
        import std.exception : enforce;

        enforce(config !is null, "Config must not be null");
        _config = config;
    }

    final Support support() @nogc nothrow pure @safe
    out (_support; _support !is null)
    {
        return _support;
    }

    final void support(Support support) pure @safe
    {
        import std.exception : enforce;

        enforce(support !is null, "Support must not be null");
        _support = support;
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

    final Resource resource() @nogc nothrow pure @safe
    out (_resource; _resource !is null)
    {
        return _resource;
    }

    final void resource(Resource resource) pure @safe
    {
        import std.exception : enforce;

        enforce(resource !is null, "Resource must not be null");
        _resource = resource;
    }
}
