module core.components.uni_component;

import core.components.units.simple_unit : SimpleUnit;
import core.components.attributes : Service;
import core.configs.config : Config;
import core.clis.cli : Cli;
import core.contexts.context : Context;
import core.supports.support : Support;
import core.resources.resource : Resource;
import core.apps.caps.cap_core : CapCore;
import core.events.bus.event_bus : EventBus;
import core.locators.service_locator : ServiceLocator;

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

    bool isComponentInitialized;
    bool isComponentCreated;
    bool isComponentDisposed;

    protected
    {
        @Service Context _context;
        @Service Logger _logger;
        @Service Config _config;
        @Service Cli _cli;
        @Service Resource _resource;
        @Service Support _support;
        @Service CapCore _capCore;
        @Service EventBus _eventBus;
        @Service ServiceLocator _locator;
    }

    void build(UniComponent uniComponent)
    {
        buildFromParent(uniComponent, this);
    }

    void buildInit(UniComponent component)
    {
        build(component);
        initialize(component);
    }

    void buildInitCreate(UniComponent component)
    {
        buildInit(component);
        create(component);
    }

    void buildInitCreateRun(UniComponent component)
    {
        buildInitCreate(component);
        run(component);
    }

    protected void buildFromParent(C : UniComponent)(C uniComponent, C parentComponent)
    {
        if (!uniComponent)
        {
            throw new Exception("Component must not be null");
        }

        if (!parentComponent)
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
            uniComponent.beforeBuild;
        }

        import std.traits : hasUDA;
        import core.utils.types : hasOverloads;

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
            uniComponent.afterBuild;
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

    alias initialize = SimpleUnit.initialize;
    alias create = SimpleUnit.create;
    alias run = SimpleUnit.run;
    alias stop = SimpleUnit.stop;
    alias dispose = SimpleUnit.dispose;

    override void initialize()
    {
        assert(!isComponentDisposed);
        super.initialize;
        isComponentInitialized = true;
        //TODO assert?
        isComponentDisposed = false;
    }

    override void create()
    {
        super.create;
        isComponentCreated = true;
        isComponentDisposed = false;
    }

    override void dispose()
    {
        super.dispose;
        isComponentDisposed = true;

        isComponentInitialized = false;
        isComponentCreated = false;
    }

    bool hasContext() const nothrow pure @safe
    {
        return _context !is null;
    }

    inout(Context) context() inout nothrow pure @safe
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

    bool hasLogger() const nothrow pure @safe
    {
        return _logger !is null;
    }

    inout(Logger) logger() inout nothrow pure @safe
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

    bool hasConfig() const nothrow pure @safe
    {
        return _config !is null;
    }

    inout(Config) config() inout nothrow pure @safe
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

    bool hasCli() const nothrow pure @safe
    {
        return _cli !is null;
    }

    inout(Cli) cli() inout nothrow pure @safe
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

    bool hasSupport() const nothrow pure @safe
    {
        return _support !is null;
    }

    inout(Support) support() inout nothrow pure @safe
    out (_support; _support !is null)
    {
        return _support;
    }

    void support(Support support) pure @safe
    {
        import std.exception : enforce;

        enforce(support !is null, "Support must not be null");
        _support = support;
    }

    bool hasResource() const nothrow pure @safe
    {
        return _resource !is null;
    }

    inout(Resource) resource() inout nothrow pure @safe
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

    bool hasCapCore() const nothrow pure @safe
    {
        return _capCore !is null;
    }

    inout(CapCore) capCore() inout nothrow pure @safe
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

    bool hasEventBus() const nothrow pure @safe
    {
        return _eventBus !is null;
    }

    inout(EventBus) eventBus() inout nothrow pure @safe
    out (_eventBus; _eventBus !is null)
    {
        return _eventBus;
    }

    void eventBus(EventBus bus) pure @safe
    {
        import std.exception : enforce;

        enforce(bus !is null, "Event bus must not be null");
        _eventBus = bus;
    }

    bool hasLocator() const nothrow pure @safe
    {
        return _locator !is null;
    }

    inout(ServiceLocator) locator() inout nothrow pure @safe
    out (_locator; _locator !is null)
    {
        return _locator;
    }

    void locator(ServiceLocator locator) pure @safe
    {
        import std.exception : enforce;

        enforce(locator !is null, "Service locator must not be null");
        _locator = locator;
    }
}
