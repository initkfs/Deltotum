module deltotum.core.applications.components.uni.uni_component;

import deltotum.core.applications.components.units.simple_unit : SimpleUnit;
import deltotum.core.applications.components.uni.attributes : Service;
import deltotum.core.configs.config : Config;
import deltotum.core.supports.support : Support;
import deltotum.core.clis.cli : Cli;
import deltotum.core.contexts.context : Context;
import deltotum.core.resources.resource : Resource;
import deltotum.core.extensions.extension : Extension;

import std.logger.core : Logger;

/**
 * Authors: initkfs
 */
class UniComponent : SimpleUnit
{
    bool isBuilt;
    bool isAllowRebuild;
    bool isCallAfterBuild = true;
    bool isCallBeforeBuild = true;

    private
    {
        @Service Context _context;
        @Service Logger _logger;
        @Service Config _config;
        @Service Cli _cli;
        @Service Support _support;
        @Service Resource _resource;
        @Service Extension _extension;
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

        if (uniComponent.isBuilt && !isAllowRebuild)
        {
            throw new Exception("Component already built: " ~ uniComponent.className);
        }

        if (!parentComponent.isBuilt)
        {
            throw new Exception("Parent component not built: " ~ parentComponent.className);
        }

        if (isCallBeforeBuild)
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

        if (isCallAfterBuild)
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

    final bool hasContext() @nogc nothrow pure @safe
    {
        return _context !is null;
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

    final bool hasLogger() @nogc nothrow pure @safe
    {
        return _logger !is null;
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

    final bool hasConfig() @nogc nothrow pure @safe
    {
        return _config !is null;
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

    final bool hasSupport() @nogc nothrow pure @safe
    {
        return _support !is null;
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

    final bool hasCli() @nogc nothrow pure @safe
    {
        return _cli !is null;
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

    final bool hasResource() @nogc nothrow pure @safe
    {
        return _resource !is null;
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

    final bool hasExtension() @nogc nothrow pure @safe
    {
        return _extension !is null;
    }

    final Extension extension() @nogc nothrow pure @safe
    out (_extension; _extension !is null)
    {
        return _extension;
    }

    final void extension(Extension extension) pure @safe
    {
        import std.exception : enforce;

        enforce(extension !is null, "Extension must not be null");
        _extension = extension;
    }
}
