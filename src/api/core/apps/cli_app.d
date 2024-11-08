module api.core.apps.cli_app;

import api.core.components.units.simple_unit : SimpleUnit;
import api.core.apps.crashes.crash_handler : CrashHandler;
import api.core.apps.app_init_ret : AppInitRet;
import api.core.components.uni_component : UniComponent;
import api.core.loggers.logging : Logging;
import api.core.configs.configs : Configuration;
import api.core.configs.keyvalues.config : Config;
import api.core.clis.cli : Cli;
import api.core.clis.printers.cli_printer : CliPrinter;
import api.core.contexts.platforms.platform_context : PlatformContext;
import api.core.contexts.context : Context;
import api.core.supports.support : Support;
import api.core.contexts.apps.app_context : AppContext;
import api.core.resources.resource : Resource;
import api.core.apps.caps.cap_core : CapCore;
import api.core.events.bus.event_bus : EventBus;
import api.core.events.bus.core_bus_events : CoreBusEvents;
import api.core.locators.service_locator : ServiceLocator;
import api.core.mem.memory : Memory;
import api.core.mem.allocs.allocator : Allocator;
import api.core.mem.allocs.mallocator : Mallocator;
import api.core.supports.errors.err_status : ErrStatus;

import CoreEnvKeys = api.core.core_env_keys;

import std.logger : Logger;
import std.typecons : Nullable;
import std.getopt : GetoptResult;

/**
 * Authors: initkfs
 */
class CliApp : SimpleUnit
{
    bool isStopMainController = true;
    bool isStrictConfigs = true;

    string defaultDataDir = "data";
    string defaultConfigsDir = "configs";
    string defaultUserDataDir = "userdata";
    string defaultResourcesDir = "resources";

    CrashHandler[] crashHandlers;

    private
    {
        UniComponent _uniServices;

        bool isSilentMode;
        bool isDebugMode;
        string cliDataDir;
        string cliConfigDir;
        size_t cliStartupDelayMs;
    }

    AppInitRet initialize(string[] args)
    {
        super.initialize;

        try
        {
            createCrashHandlers(args);

            _uniServices = newUniServices;
            assert(_uniServices);

            uservices.capCore = newCapCore;

            auto cli = createCli(args);
            assert(cli);
            uservices.cli = cli;

            auto cliResult = parseCli(uservices.cli);
            if (!isSilentMode)
            {
                import std.stdio : writeln, writefln;

                writeln("Received cli: ", cli.cliArgs);
                writefln("Config dir: '%s', data dir: '%s', debug: %s, silent: %s, wait ms: %s",
                    cliConfigDir, cliDataDir, isDebugMode, isSilentMode, cliStartupDelayMs);
            }

            cli.isSilentMode = isSilentMode;

            if (cliResult.helpWanted)
            {
                cli.printHelp(cliResult);
                return AppInitRet(isExit : true, isInit:
                    false);
            }

            if (cliStartupDelayMs > 0)
            {
                import std.conv : text;

                cli.printIfNotSilent(text("Startup delay: ", cliStartupDelayMs, " ms"));

                import core.thread.osthread : Thread;
                import core.time : dur;

                Thread.sleep(dur!"msecs"(cliStartupDelayMs));
                cli.printIfNotSilent("Startup delay end");
            }

            if (isDebugMode)
            {
                cli.printIfNotSilent("Debug mode active");
            }

            uservices.support = createSupport;
            assert(uservices.support);

            uservices.context = createContext;
            assert(uservices.context);

            uservices.eventBus = createEventBus(uservices.context);
            assert(uservices.eventBus);
            version (EventBusCoreEvents)
            {
                uservices.eventBus.fire(CoreBusEvents.build_context, uservices.context);
                uservices.eventBus.fire(CoreBusEvents.build_event_bus, uservices.eventBus);
            }

            uservices.configs = createConfiguration(uservices.context);
            assert(uservices.config);
            version (EventBusCoreEvents)
            {
                uservices.eventBus.fire(CoreBusEvents.build_config, uservices.config);
            }

            uservices.logging = createLogging(uservices.support);
            assert(uservices.logging);
            version (EventBusCoreEvents)
            {
                uservices.eventBus.fire(CoreBusEvents.build_logging, uservices.logging);
            }

            uservices.memory = createMemory(uservices.logging, uservices.config, uservices
                    .context);
            assert(uservices.memory);
            uservices.logger.trace("Service memory built");
            version (EventBusCoreEvents)
            {
                uservices.eventBus.fire(CoreBusEvents.build_memory, uservices.alloc);
            }

            uservices.resource = createResource(uservices.logging, uservices.config, uservices
                    .context);
            assert(uservices.resource);
            uservices.logger.trace("Resources service built");
            version (EventBusCoreEvents)
            {
                uservices.eventBus.fire(CoreBusEvents.build_resource, uservices.resource);
            }

            uservices.locator = createLocator(uservices.logging, uservices.config, uservices
                    .context);
            assert(uservices.locator);
            uservices.logger.trace("Service locator built");
            version (EventBusCoreEvents)
            {
                uservices.eventBus.fire(CoreBusEvents.build_locator, uservices.locator);
            }

            uservices.isBuilt = true;
            version (EventBusCoreEvents)
            {
                uservices.eventBus.fire(CoreBusEvents.build_core_services, uservices);
            }
        }
        catch (Exception e)
        {
            consumeThrowable(e, true);
        }

        return AppInitRet(false, true);
    }

    void exit(int code = 0)
    {
        assert(uservices.context);
        uservices.context.appContext.exit(code);
    }

    UniComponent newUniServices() => new UniComponent;

    CapCore newCapCore() => new CapCore;

    protected void consumeThrowable(Throwable ex, bool isRethrow = true)
    {
        try
        {
            foreach (handler; crashHandlers)
            {
                handler.acceptCrash(ex);
                if (handler.isConsumed)
                {
                    break;
                }
            }
        }
        catch (Exception exFromHandler)
        {
            exFromHandler.next = ex;
            if (uservices.logging)
            {
                uservices.logger.errorf("Exception from error handler: %s", exFromHandler);
            }
            else
            {
                import std.stdio : stderr;

                stderr.writefln("Unlogged exception from error handler: %s", exFromHandler);
            }
        }
        finally
        {
            if (uservices.logging)
            {
                uservices.logger.errorf("Error from application. %s", ex);
            }

            if (isRethrow)
            {
                throw ex;
            }
        }
    }

    GetoptResult parseCli(Cli cliManager)
    {
        assert(cliManager);

        import std.getopt : config;

        GetoptResult cliResult = cliManager.parse(
            config.passThrough,
            "c|configdir", "Config directory", &cliConfigDir,
            "d|data", "Application data directory.", &cliDataDir,
            "g|debug", "Debug mode", &isDebugMode,
            "s|silent", "Silent mode, less information in program output.", &isSilentMode,
            "w|wait", "Startup delay (ms)", &cliStartupDelayMs);
        return cliResult;
    }

    protected Context createContext()
    {
        assert(uservices.cli);

        import std.path : dirName, buildPath, isAbsolute;
        import std.file : exists, isDir, isFile;

        const string curDir = currentDir;
        uservices.cli.printIfNotSilent(
            "Current working directory: " ~ curDir);
        string dataDirectory;
        if (cliDataDir)
        {
            dataDirectory = cliDataDir;
            uservices.cli.printIfNotSilent(
                "Received data directory from cli: " ~ dataDirectory);
            if (!dataDirectory.isAbsolute)
            {
                dataDirectory = buildPath(curDir, dataDirectory);
                uservices.cli.printIfNotSilent(
                    "Convert data directory from cli to absolute path: " ~ dataDirectory);
            }
        }
        else
        {
            const relDataDir = buildPath(curDir, defaultDataDir);
            if (relDataDir.exists && relDataDir
                .isDir)
            {
                dataDirectory = relDataDir;
                uservices.cli.printIfNotSilent(
                    "Default data directory will be used: " ~ dataDirectory);
            }
        }

        string userDir;
        const relUserDir = buildPath(dataDirectory, defaultUserDataDir);
        if (relUserDir.exists && relUserDir.isDir)
        {
            userDir = relUserDir;
            uservices.cli.printIfNotSilent(
                "Found user directory: " ~ userDir);
        }
        else
        {
            uservices.cli.printIfNotSilent(
                "User directory not found");
        }

        const appContext = newAppContext(curDir, dataDirectory, userDir, isDebugMode, isSilentMode);
        const platformContext = newPlatformContext;
        auto context = newContext(appContext, platformContext);
        return context;
    }

    AppContext newAppContext(string curDir, string dataDir, string userDir, bool isDebugMode, bool isSilentMode)
    {
        return new AppContext(curDir, dataDir, userDir, isDebugMode, isSilentMode);
    }

    PlatformContext newPlatformContext()
    {
        return new PlatformContext;
    }

    Context newContext(const AppContext appContext, const PlatformContext platformContext)
    {
        return new Context(appContext, platformContext);
    }

    Config newConfigFromFile(string configFile)
    {
        import std.algorithm.searching : startsWith;
        import std.path : extension;

        import api.core.configs.keyvalues.properties.property_config : PropertyConfig;

        string ext = configFile.extension;
        if (ext.startsWith(".") && ext.length > 1)
        {
            ext = ext[1 .. $];
        }
        switch (ext)
        {
            case "config":
                return new PropertyConfig(configFile);
            default:
                break;
        }

        throw new Exception(
            "Not supported config: " ~ configFile);
    }

    Config newConfigAggregator(Config[] forConfigs)
    {
        import api.core.configs.keyvalues.config_aggregator : ConfigAggregator;

        return new ConfigAggregator(forConfigs);
    }

    Config newAAConstConfig()
    {
        import api.core.configs.keyvalues.aa_const_config : AAConstConfig;
        import std.process : environment;

        auto envAA = environment.toAA;
        return new AAConstConfig!string(envAA);
    }

    protected Config createConfig(Context context)
    {
        assert(uservices.cli);
        assert(context);

        import std.path : buildPath, isAbsolute;

        string configDir = cliConfigDir;
        if (configDir)
        {
            uservices.cli.printIfNotSilent(
                "Received config directory from cli: " ~ configDir);
            if (!configDir.isAbsolute)
            {
                const mustBeDataDir = context
                    .appContext.dataDir;
                if (
                    mustBeDataDir.isNull)
                {
                    throw new Exception("Config path directory from cli is relative, but the data directory was not found in application context");
                }
                configDir = buildPath(mustBeDataDir.get, configDir);
                uservices.cli.printIfNotSilent(
                    "Convert config directory path from cli to absolute path: " ~ configDir);
            }
        }
        else
        {
            const mustBeDataDir = context
                .appContext.dataDir;
            if (
                !mustBeDataDir.isNull)
            {
                configDir = buildPath(mustBeDataDir.get, defaultConfigsDir);
                uservices.cli.printIfNotSilent(
                    "Default config directory will be used: " ~ configDir);
            }
            else
            {
                uservices.cli.printIfNotSilent(
                    "Default config path cannot be built: data directory not found");
            }

        }

        auto envConfig = newAAConstConfig;
        uservices.cli.printIfNotSilent("Create config from environment");
        envConfig.isThrowOnNotExistentKey = isStrictConfigs;
        envConfig.isThrowOnSetValueNotExistentKey = isStrictConfigs;

        Config[] configs = [envConfig]; //TODO is hidden

        if (configDir.length != 0)
        {
            import std.file : isDir, exists;

            if (!configDir.exists || !configDir.isDir)
            {
                uservices.cli.printIfNotSilent(
                    "Config directory does not exist or not a directory: " ~ configDir);
            }
            else
            {
                import api.core.configs.keyvalues.properties.property_config : PropertyConfig;
                import api.core.configs.keyvalues.config_aggregator : ConfigAggregator;
                import std.file : dirEntries, SpanMode;
                import std.algorithm.iteration : filter;
                import std.algorithm.searching : endsWith;

                foreach (configPath; dirEntries(configDir, SpanMode
                        .depth).filter!(f => f.isFile))
                {
                    auto newConfig = newConfigFromFile(
                        configPath.name);
                    newConfig.isThrowOnNotExistentKey = isStrictConfigs;
                    newConfig.isThrowOnSetValueNotExistentKey = isStrictConfigs;
                    configs ~= newConfig;
                    uservices.cli.printIfNotSilent(
                        "Load config: " ~ configPath.name);
                }
            }
        }
        else
        {
            uservices.cli.printIfNotSilent(
                "Path to config directory is empty");
        }

        auto config = newConfigAggregator(configs);
        config.isThrowOnNotExistentKey = isStrictConfigs;
        config.isThrowOnSetValueNotExistentKey = isStrictConfigs;
        immutable bool isLoad = config.load;
        import std.format : format;

        if (isLoad)
        {
            uservices.cli.printIfNotSilent(format("Load %s configs", configs
                    .length));
        }
        else
        {
            uservices.cli.printIfNotSilent("Configs were not loaded");
        }

        return config;
    }

    protected Configuration createConfiguration(Context context)
    {
        auto config = createConfig(context);
        assert(config);
        return newConfiguration(config);
    }

    protected Configuration newConfiguration(Config config)
    {
        return new Configuration(config);
    }

    protected Logger createLogger(Support support)
    {
        assert(support);

        import std.logger : MultiLogger, FileLogger, LogLevel, Logger;

        auto multiLogger = new MultiLogger(
            LogLevel.trace);
        import std.stdio : stdout;

        enum consoleLoggerLevel = LogLevel.trace;
        auto consoleLogger = new FileLogger(stdout, consoleLoggerLevel);
        const string consoleLoggerName = "logger_stdout";
        multiLogger.insertLogger(consoleLoggerName, consoleLogger);

        import std.format : format;

        auto errLogger = new class Logger
        {
            this()
            {
                super(LogLevel.warning);
            }

            override void writeLogMsg(ref LogEntry payload) @trusted
            {
                auto logLevel = payload.logLevel;
                auto dt = payload.timestamp;
                string message = format("%02d:%02d %s %s(%d): %s", dt.hour(), dt.minute(),
                    payload.logLevel, payload.moduleName, payload.line, payload.msg);
                support.errStatus.error(message);
            }
        };

        multiLogger.insertLogger("Error logging", errLogger);

        multiLogger.tracef(
            "Create stdout logging, name '%s', level '%s'",
            consoleLoggerName, consoleLoggerLevel);

        return multiLogger;
    }

    protected Logging createLogging(Support support)
    {
        auto logger = createLogger(support);
        assert(logger);
        return newLogging(logger);
    }

    protected Logging newLogging(Logger logger)
    {
        return new Logging(logger);
    }

    protected Support createSupport()
    {
        auto errStatus = new ErrStatus;

        auto support = newSupport(errStatus);
        return support;
    }

    Support newSupport(ErrStatus errStatus)
    {
        return new Support(errStatus);
    }

    protected Resource createResource(Logging logging, Config config, Context context)
    {
        assert(logging);
        assert(config);
        assert(context);

        import std.path : buildPath, isAbsolute;
        import std.file : exists, isDir;

        string mustBeResDir = defaultResourcesDir;
        if (mustBeResDir.length == 0)
        {
            logging.logger.infof(
                "Resource path is empty, empty resource manager created");
            //WARNING return
            return newResource(logging);
        }

        if (mustBeResDir.isAbsolute)
        {
            if (!mustBeResDir.exists || !mustBeResDir
                .isDir)
            {
                logging.logger.error(
                    "Absolute resources directory path does not exist or not a directory: ", mustBeResDir);
                //WARNING return
                return newResource(logging);
            }
        }
        else
        {
            const mustBeDataDir = context
                .appContext.dataDir;
            if (mustBeDataDir.isNull)
            {
                logging.logger.infof(
                    "Received relative path '%s', but data directory not found", mustBeResDir);
                //WARNING return
                return newResource(logging);
            }

            mustBeResDir = buildPath(mustBeDataDir.get, mustBeResDir);
            if (!mustBeResDir.exists || !mustBeResDir
                .isDir)
            {
                logging.logger.warning(
                    "Resource directory path relative to the data does not exist or is not a directory: ", mustBeResDir);
                //WARNING return
                return newResource(logging);
            }
        }

        auto resource = newResource(logging, mustBeResDir);
        logging.logger.trace(
            "Create resources from directory: ", mustBeResDir);
        return resource;
    }

    Resource newResource(Logging logging, string resourcesDir = null)
    {
        return new Resource(logging, resourcesDir);
    }

    protected EventBus createEventBus(Context context)
    {
        return newEventBus;
    }

    EventBus newEventBus()
    {
        return new EventBus;
    }

    protected ServiceLocator createLocator(Logging logging, Config config, Context context)
    {
        return newServiceLocator(logging);
    }

    ServiceLocator newServiceLocator(
        Logging logging)
    {
        return new ServiceLocator(logging);
    }

    Mallocator newMallocator()
    {
        return new Mallocator;
    }

    Allocator createAllocator(Logging logging, Config config, Context context)
    {
        return newMallocator;
    }

    Memory newMemory(Allocator allocator)
    {
        return new Memory(allocator);
    }

    Memory createMemory(Logging logging, Config config, Context context)
    {
        auto alloc = createAllocator(logging, config, context);
        return newMemory(alloc);
    }

    protected Cli createCli(string[] args)
    {
        auto printer = newCliPrinter;
        auto cli = newCli(args, printer);
        return cli;
    }

    CliPrinter newCliPrinter()
    {
        return new CliPrinter;
    }

    Cli newCli(string[] args, CliPrinter printer)
    {
        return new Cli(args, printer);
    }

    bool isWriteCrashFile()
    {
        import std.process : environment;
        import std.conv : to;

        immutable mustBeIsDisableCrash = environment.get(
            CoreEnvKeys.appCrashFileDisable);
        if (!mustBeIsDisableCrash)
        {
            return true;
        }

        immutable bool isDisable = mustBeIsDisableCrash.to!bool;
        return !isDisable;
    }

    protected void createCrashHandlers(
        string[] args)
    {
        import std.path : dirName, buildPath, isAbsolute;
        import std.file : exists, isDir, isFile, getcwd;
        import std.process : environment;
        import std.format : format;

        if (!isWriteCrashFile)
        {
            return;
        }

        string crashDir = getcwd;

        immutable mustBeCrashDir = environment.get(
            CoreEnvKeys.appCrashDir);
        if (mustBeCrashDir)
        {
            if (!mustBeCrashDir.exists || !mustBeCrashDir
                .isDir)
            {
                throw new Exception(format(
                        "Crash directory from environment key %s does not exist or not a directory: %s",
                        CoreEnvKeys.appCrashDir, mustBeCrashDir));
            }
            crashDir = mustBeCrashDir;
        }

        import api.core.apps.crashes.file_crash_handler : FileCrashHandler;

        crashHandlers ~= new FileCrashHandler(
            crashDir);
    }

    string currentDir()
    {
        import std.file : getcwd;

        return getcwd;
    }

    void build(UniComponent component)
    {
        assert(uservices);
        uservices.build(component);
    }

    UniComponent uservices() nothrow pure @safe
    out (_uniServices; _uniServices !is null)
    {
        return _uniServices;
    }

    void uservices(UniComponent services) pure @safe
    {
        import std.exception : enforce;

        enforce(services !is null, "Services must not be null");
        _uniServices = services;
    }
}
