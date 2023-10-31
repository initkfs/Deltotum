module deltotum.core.apps.uni.uni_component;

import deltotum.core.apps.units.simple_unit : SimpleUnit;
import deltotum.core.apps.uni.attributes : Service;
import deltotum.core.configs.config : Config;
import deltotum.core.clis.cli : Cli;
import deltotum.core.contexts.context : Context;
import deltotum.core.resources.resource : Resource;
import deltotum.core.extensions.extension : Extension;
import deltotum.core.apps.caps.cap_core : CapCore;

import std.logger.core : Logger;

/**
 * Authors: initkfs
 */
class UniComponent : SimpleUnit
{
    bool isBuilt;
    bool isAllowRebuild;
    bool isAllowRebuildServices;

    bool isCallBeforeBuild;
    bool isCallAfterBuild;

    bool delegate(UniComponent component, UniComponent) onPreBuildWithParentIsContinue;
    void delegate(UniComponent component, UniComponent) onPostBuildWithParent;

    private
    {
        @Service Context _context;
        @Service Logger _logger;
        @Service Config _config;
        @Service Cli _cli;
        @Service Resource _resource;
        @Service Extension _ext;
        @Service CapCore _capCore;
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

        if (uniComponent.isBuilt && !uniComponent.isAllowRebuild)
        {
            throw new Exception("Component already built: " ~ uniComponent.className);
        }

        if (!parentComponent.isBuilt)
        {
            throw new Exception("Parent component not built: " ~ parentComponent.className);
        }

        if (uniComponent.onPreBuildWithParentIsContinue
            && (!uniComponent.onPreBuildWithParentIsContinue(uniComponent, parentComponent)))
        {
            return;
        }

        if (uniComponent.isCallBeforeBuild)
        {
            uniComponent.beforeBuild();
        }

        import std.traits : hasUDA;
        import deltotum.core.utils.type_util : hasOverloads;

        alias parentType = typeof(parentComponent);
        static foreach (const fieldName; __traits(allMembers, parentType))
        {
            static if (!hasOverloads!(parentType, fieldName) && hasUDA!(__traits(getMember, parentComponent, fieldName), Service))
            {
                {
                    import std.algorithm.searching : startsWith;
                    import std.uni : toUpper;

                    enum fieldSetterName = (fieldName.startsWith("_") ? fieldName[1 .. $]
                                : fieldName);
                    enum hasMethodName = "has" ~ fieldSetterName[0 .. 1].toUpper ~ fieldSetterName[1 .. $];
                    immutable bool hasService = __traits(getMember, uniComponent, hasMethodName)();
                    if (!hasService || uniComponent.isAllowRebuildServices)
                    {
                        __traits(getMember, uniComponent, fieldSetterName) = __traits(getMember, parentComponent, fieldSetterName);
                    }
                }

            }
        }

        if (uniComponent.isCallAfterBuild)
        {
            uniComponent.afterBuild();
        }

        uniComponent.isBuilt = true;

        if (uniComponent.onPostBuildWithParent)
        {
            uniComponent.onPostBuildWithParent(uniComponent, parentComponent);
        }
    }

    void beforeBuild()
    {

    }

    void afterBuild()
    {

    }

    bool hasContext() const @nogc nothrow pure @safe
    {
        return _context !is null;
    }

    inout(Context) context() inout @nogc nothrow pure @safe
    out (_context; _context !is null)
    {
        return _context;
    }

    void context(Context context) pure @safe
    {
        import std.exception : enforce;

        enforce(context !is null, "Context must not be null");
        _context = context;
    }

    bool hasLogger() const @nogc nothrow pure @safe
    {
        return _logger !is null;
    }

    inout(Logger) logger() inout @nogc nothrow pure @safe
    out (_logger; _logger !is null)
    {
        return _logger;
    }

    void logger(Logger logger) pure @safe
    {
        import std.exception : enforce;

        enforce(logger !is null, "Logger must not be null");
        _logger = logger;

    }

    bool hasConfig() const @nogc nothrow pure @safe
    {
        return _config !is null;
    }

    inout(Config) config() inout @nogc nothrow pure @safe
    out (_config; _config !is null)
    {
        return _config;
    }

    void config(Config config) pure @safe
    {
        import std.exception : enforce;

        enforce(config !is null, "Config must not be null");
        _config = config;
    }

    bool hasCli() const @nogc nothrow pure @safe
    {
        return _cli !is null;
    }

    inout(Cli) cli() inout @nogc nothrow pure @safe
    out (_cli; _cli !is null)
    {
        return _cli;
    }

    void cli(Cli cli) pure @safe
    {
        import std.exception : enforce;

        enforce(cli !is null, "Cli must not be null");
        _cli = cli;
    }

    bool hasResource() const @nogc nothrow pure @safe
    {
        return _resource !is null;
    }

    inout(Resource) resource() inout @nogc nothrow pure @safe
    out (_resource; _resource !is null)
    {
        return _resource;
    }

    void resource(Resource resource) pure @safe
    {
        import std.exception : enforce;

        enforce(resource !is null, "Resource must not be null");
        _resource = resource;
    }

    bool hasExt() const @nogc nothrow pure @safe
    {
        return _ext !is null;
    }

    inout(Extension) ext() inout @nogc nothrow pure @safe
    out (_ext; _ext !is null)
    {
        return _ext;
    }

    void ext(Extension ext) pure @safe
    {
        import std.exception : enforce;

        enforce(ext !is null, "Extension must not be null");
        _ext = ext;
    }

    bool hasCapCore() const @nogc nothrow pure @safe
    {
        return _capCore !is null;
    }

    inout(CapCore) capCore() inout @nogc nothrow pure @safe
    out (_capCore; _capCore !is null)
    {
        return _capCore;
    }

    void capCore(CapCore cap) pure @safe
    {
        import std.exception : enforce;

        enforce(cap !is null, "Core capabilities must not be null");
        _capCore = cap;
    }
}
