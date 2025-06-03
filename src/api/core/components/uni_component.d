module api.core.components.uni_component;

import api.core.components.units.simple_unit : SimpleUnit;
import api.core.components.uda : Service;
import api.core.contexts.context : Context;
import api.core.contexts.apps.app_context : AppContext;
import api.core.contexts.platforms.platform_context : PlatformContext;
import api.core.loggers.logging : Logging;

import api.core.configs.configs : Configuration;
import api.core.configs.keyvalues.config : Config;
import api.core.clis.cli : Cli;
import api.core.supports.support : Support;
import api.core.resources.locals.local_resources : LocalResources;
import api.core.resources.resourcing : Resourcing;
import api.core.caps.cap : Cap;
import api.core.caps.core.cap_core : CapCore;
import api.core.events.event_bridge : EventBridge;
import api.core.events.bus.event_bus : EventBus;
import api.core.depends.dep : Dep;
import api.core.depends.locators.service_locator : ServiceLocator;
import api.core.mems.memory : Memory;
import api.core.util.allocs.allocator : Allocator;

import std.logger : Logger;

/**
 * Authors: initkfs
 */
class UniComponent : SimpleUnit
{
    bool isBuilt;
    bool isAllowRebuild;
    bool isAllowRebuildServices;

    bool isStrictState = true;

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
        @Service Logging _logging;
        @Service Configuration _configs;
        @Service Memory _memory;
        @Service Cli _cli;
        @Service Resourcing _resources;
        @Service Support _support;
        @Service Cap _cap;
        @Service EventBridge _eventBridge;
        @Service Dep _dep;
    }

    void build(UniComponent uniComponent)
    {
        buildFromParent(uniComponent, this);
    }

    void buildInit(UniComponent component)
    {
        build(component);

        if (isStrictState && !component.isBuilt)
        {
            throw new Exception("Component not built: " ~ component.className);
        }

        initialize(component);

        if (isStrictState && !component.isInitialized)
        {
            throw new Exception("Component not initialized: " ~ component.className);
        }
    }

    void buildInitCreate(UniComponent component)
    {
        buildInit(component);
        create(component);

        if (isStrictState && !component.isCreated)
        {
            throw new Exception("Component not created: " ~ component.className);
        }
    }

    void buildInitCreateRun(UniComponent component)
    {
        buildInitCreate(component);
        run(component);

        if (isStrictState && !component.isRunning)
        {
            throw new Exception("Component not running: " ~ component.className);
        }
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
        import api.core.utils.types : hasOverloads;

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

    bool hasContext() const nothrow pure @safe => _context !is null;
    const(AppContext) appContext() pure @safe => context.appContext;
    const(PlatformContext) platformContext() pure @safe => context.platformContext;

    inout(Context) context() inout nothrow pure @safe
    out (_context; _context !is null)
    {
        return _context;
    }

    void context(Context context) pure @safe
    {
        import std.exception : enforce;

        enforce(context, "Context must not be null");
        _context = context;
    }

    bool hasLogging() const nothrow pure @safe => _logging !is null;
    inout(Logger) logger() inout nothrow pure @safe => logging.logger;

    inout(Logging) logging() inout nothrow pure @safe
    out (_logging; _logging !is null)
    {
        return _logging;
    }

    void logging(Logging newLoggers) pure @safe
    {
        import std.exception : enforce;

        enforce(newLoggers !is null, "Logging must not be null");
        _logging = newLoggers;

    }

    bool hasConfigs() const nothrow pure @safe => _configs !is null;
    inout(Config) config() inout nothrow pure @safe => configs.config;

    inout(Configuration) configs() inout nothrow pure @safe
    out (_configs; _configs !is null)
    {
        return _configs;
    }

    void configs(Configuration newConfigs) pure @safe
    {
        import std.exception : enforce;

        enforce(newConfigs !is null, "Configuration must not be null");
        _configs = newConfigs;
    }

    bool hasMemory() const nothrow pure @safe => _memory !is null;
    inout(Allocator!ubyte) alloc() inout nothrow pure @safe => memory.alloc;

    inout(Memory) memory() inout nothrow pure @safe
    out (_memory; _memory !is null)
    {
        return _memory;
    }

    void memory(Memory newMemory) pure @safe
    {
        import std.exception : enforce;

        enforce(newMemory !is null, "Service memory must not be null");
        _memory = newMemory;
    }

    bool hasCli() const nothrow pure @safe => _cli !is null;

    inout(Cli) cli() inout nothrow pure @safe
    out (_cli; _cli !is null)
    {
        return _cli;
    }

    void cli(Cli cli) pure @safe
    {
        import std.exception : enforce;

        enforce(cli !is null, "CLI must not be null");
        _cli = cli;
    }

    bool hasSupport() const nothrow pure @safe => _support !is null;

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

    bool hasResources() const nothrow pure @safe => _resources !is null;
    inout(LocalResources) reslocal() inout pure @safe => resources.local;

    inout(Resourcing) resources() inout nothrow pure @safe
    out (_resources; _resources !is null)
    {
        return _resources;
    }

    void resources(Resourcing resources) pure @safe
    {
        import std.exception : enforce;

        enforce(resources !is null, "Resourcing must not be null");
        _resources = resources;
    }

    bool hasCap() const nothrow pure @safe => _cap !is null;
    inout(CapCore) capCore() inout nothrow pure @safe => cap.capCore;

    inout(Cap) cap() inout nothrow pure @safe
    out (_cap; _cap !is null)
    {
        return _cap;
    }

    void cap(Cap newCap) pure @safe
    {
        import std.exception : enforce;

        enforce(newCap !is null, "Capabilities must not be null");
        _cap = newCap;
    }

    bool hasEventBridge() const nothrow pure @safe => _eventBridge !is null;
    inout(EventBus) eventBus() inout nothrow pure @safe => eventBridge.eventBus;

    inout(EventBridge) eventBridge() inout nothrow pure @safe
    out (_eventBridge; _eventBridge !is null)
    {
        return _eventBridge;
    }

    void eventBridge(EventBridge eb) pure @safe
    {
        import std.exception : enforce;

        enforce(eb !is null, "Event bridge must not be null");
        _eventBridge = eb;
    }

    bool hasDep() const nothrow pure @safe => _dep !is null;
    inout(ServiceLocator) locator() inout nothrow pure @safe => dep.locator;

    inout(Dep) dep() inout nothrow pure @safe
    out (_dep; _dep !is null)
    {
        return _dep;
    }

    void dep(Dep newDep) pure @safe
    {
        import std.exception : enforce;

        enforce(newDep !is null, "Dependency service must not be null");
        _dep = newDep;
    }
}
