module api.core.apps.cli_app;

import api.core.components.units.simple_unit : SimpleUnit;
import api.core.apps.crashes.crash_handler : CrashHandler;
import api.core.components.uni_component : UniComponent;
import api.core.loggers.logging : Logging;
import api.core.configs.configs : Configuration;
import api.core.configs.keyvalues.config : Config;
import api.core.clis.cli : Cli;
import api.core.clis.printers.cli_printer : CliPrinter;
import api.core.clis.parsers.cli_parser : CliParser;
import api.core.contexts.platforms.platform_context : PlatformContext;
import api.core.contexts.context : Context;
import api.core.supports.support : Support;
import api.core.contexts.apps.app_context : AppContext;
import api.core.resources.locals.local_resources : LocalResources;
import api.core.resources.resourcing : Resourcing;
import api.core.contexts.locators.locator_context : LocatorContext;
import api.core.mems.memory : Memory;
import api.core.utils.allocs.allocator : Allocator;
import api.core.utils.allocs.mallocator : Mallocator;
import api.core.utils.allocs.arena_allocator : ArenaAllocator;
import api.core.supports.errors.err_status : ErrStatus;
import api.core.supports.decisions.decision_system : DecisionSystem;

import CoreEnvKeys = api.core.core_env_keys;

import api.core.loggers.builtins.logger : Logger;
import std.typecons : Nullable;
import std.getopt : GetoptResult;

/**
 * Authors: initkfs
 */
class CliApp : SimpleUnit
{
    string appname = "app";
    string appver = "0.1";
    string appid = "app.app";

    bool isStopMainController = true;

    string defaultDataDir = "data";
    string defaultConfigsDir = "configs";
    string defaultUserDataDir = "userdata";
    string defaultResourcesDir = "resources";

    CrashHandler[] crashHandlers;

    int exitCode;

    private
    {
        UniComponent _uniServices;

        bool isSilentMode;
        bool isDebugMode;
        string cliDataDir;
        string cliConfigDir;
        size_t cliStartupDelayMs;
    }

    bool initialize(string[] args)
    {
        super.initialize;

        try
        {
            createCrashHandlers(args);

            _uniServices = newUniServices;
            assert(_uniServices);

            auto cli = createCli(args);
            assert(cli);
            uservices.cli = cli;

            auto cliResult = parseCli(uservices.cli);
            cli.printer.isSilentMode = isSilentMode;

            if (cliResult.helpWanted)
            {
                cli.printer.printHelp(cliResult);
                return false;
            }

            if (cliStartupDelayMs > 0)
            {
                import std.conv : text;

                cli.printer.printIfNotSilent(text("Startup delay: ", cliStartupDelayMs, " ms"));

                import core.thread.osthread : Thread;
                import core.time : dur;

                Thread.sleep(dur!"msecs"(cliStartupDelayMs));
                cli.printer.printIfNotSilent("Startup delay end");
            }

            if (isDebugMode)
            {
                cli.printer.printIfNotSilent("Debug mode active");
            }

            uservices.support = createSupport;
            assert(uservices.support);

            uservices.context = createContext;
            assert(uservices.context);

            uservices.configs = createConfiguration(uservices.context);
            assert(uservices.config);

            uservices.logging = createLogging(uservices.support);
            assert(uservices.logging);

            uservices.memory = createMemory(uservices.logging, uservices.config, uservices
                    .context);
            assert(uservices.memory);

            uservices.resources = createResourcing(uservices.logging, uservices.config, uservices
                    .context);
            assert(uservices.resources);

            uservices.isBuilt = true;
        }
        catch (Exception e)
        {
            consumeThrowable(e, true);
        }

        return true;
    }

    override void dispose()
    {
        super.dispose;

        assert(uservices.context);
        uservices.context.app.exit(exitCode);
    }

    UniComponent newUniServices() => new UniComponent;

    void consumeThrowable(Throwable ex, bool isRethrow = false)
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
            if (uservices && uservices.logging)
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
            if (uservices && uservices.logging)
            {
                uservices.logger.error("Error from application. " ~ ex.toString);
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

        GetoptResult cliResult = cliManager.parser.parse(
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
        uservices.cli.printer.printIfNotSilent(
            "Current working directory: " ~ curDir);
        string dataDirectory;
        if (cliDataDir)
        {
            dataDirectory = cliDataDir;
            uservices.cli.printer.printIfNotSilent(
                "Received data directory from cli: " ~ dataDirectory);
            if (!dataDirectory.isAbsolute)
            {
                dataDirectory = buildPath(curDir, dataDirectory);
                uservices.cli.printer.printIfNotSilent(
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
                uservices.cli.printer.printIfNotSilent(
                    "Default data directory will be used: " ~ dataDirectory);
            }
        }

        string userDir;
        const relUserDir = buildPath(dataDirectory, defaultUserDataDir);
        if (relUserDir.exists && relUserDir.isDir)
        {
            userDir = relUserDir;
            uservices.cli.printer.printIfNotSilent(
                "Found user directory: " ~ userDir);
        }
        else
        {
            uservices.cli.printer.printIfNotSilent(
                "User directory not found");
        }

        auto app = newAppContext(curDir, dataDirectory, userDir, isDebugMode, isSilentMode);
        auto platform = newPlatformContext;

        auto locator = newServiceLocator;

        auto context = newContext(app, platform, locator);
        return context;
    }

    AppContext newAppContext(string curDir, string dataDir, string userDir, bool isDebugMode, bool isSilentMode)
    {
        return new AppContext(curDir, dataDir, userDir, isDebugMode, isSilentMode);
    }

    PlatformContext newPlatformContext() => new PlatformContext;

    LocatorContext newServiceLocator() => new LocatorContext;

    Context newContext(AppContext app, PlatformContext platform, LocatorContext locator)
    {
        return new Context(app, platform, locator);
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

        try
        {
            auto envAA = environment.toAA;
            return new AAConstConfig(envAA);
        }
        catch (Exception e)
        {
            uservices.logger.error(e.toString);
            return new AAConstConfig(new string[string]);
        }
    }

    protected Config createConfig(Context context)
    {
        assert(uservices.cli);
        assert(context);

        import std.path : buildPath, isAbsolute;

        string configDir = cliConfigDir;
        if (configDir)
        {
            uservices.cli.printer.printIfNotSilent(
                "Received config directory from cli: " ~ configDir);
            if (!configDir.isAbsolute)
            {
                const mustBeDataDir = context
                    .app.dataDir;
                if (
                    mustBeDataDir.length == 0)
                {
                    throw new Exception("Config path directory from cli is relative, but the data directory was not found in application context");
                }
                configDir = buildPath(mustBeDataDir, configDir);
                uservices.cli.printer.printIfNotSilent(
                    "Convert config directory path from cli to absolute path: " ~ configDir);
            }
        }
        else
        {
            const mustBeDataDir = context
                .app.dataDir;
            if (mustBeDataDir.length > 0)
            {
                configDir = buildPath(mustBeDataDir, defaultConfigsDir);
                uservices.cli.printer.printIfNotSilent(
                    "Default config directory will be used: " ~ configDir);
            }
            else
            {
                uservices.cli.printer.printIfNotSilent(
                    "Default config path cannot be built: data directory not found");
            }

        }

        auto envConfig = newAAConstConfig;
        uservices.cli.printer.printIfNotSilent("Create config from environment");

        Config[] configs = [envConfig]; //TODO is hidden

        if (configDir.length != 0)
        {
            import std.file : isDir, exists;

            if (!configDir.exists || !configDir.isDir)
            {
                uservices.cli.printer.printIfNotSilent(
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
                    configs ~= newConfig;
                    uservices.cli.printer.printIfNotSilent(
                        "Load config: " ~ configPath.name);
                }
            }
        }
        else
        {
            uservices.cli.printer.printIfNotSilent(
                "Path to config directory is empty");
        }

        auto config = newConfigAggregator(configs);
        immutable bool isLoad = config.load;
        import std.format : format;

        if (isLoad)
        {
            uservices.cli.printer.printIfNotSilent(format("Load %s configs", configs
                    .length));
        }
        else
        {
            uservices.cli.printer.printIfNotSilent("Configs were not loaded");
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

        import api.core.loggers.builtins.base_logger : LogLevel;
        import api.core.loggers.builtins.logger : Logger;
        import api.core.loggers.builtins.handlers.console_handler: ConsoleHandler;
        import CoreConfigKeys = api.core.core_config_keys;

        //TODO from config
        auto multiLogger = new Logger;
        multiLogger.level = LogLevel.trace;

        enum consoleLoggerLevel = LogLevel.trace;
        auto consoleLogger = new ConsoleHandler;
        consoleLogger.level = consoleLoggerLevel;
        if (CoreConfigKeys.loggerIsShowMemory)
        {
            //TODO flag   
        }

        multiLogger.add(consoleLogger);

        // auto errLogger = new class Logger
        // {
        //     this()
        //     {
        //         super(LogLevel.warning);
        //     }

        //     override void writeLogMsg(ref LogEntry payload) @trusted
        //     {
        //         auto logLevel = payload.logLevel;
        //         auto dt = payload.timestamp;
        //         string message = format("%02d:%02d %s %s(%d): %s", dt.hour(), dt.minute(),
        //             payload.logLevel, payload.moduleName, payload.line, payload.msg);
        //         support.errStatus.error(message);
        //     }
        // };

        multiLogger.tracef(
            "Create stdout logging, level '%s'", consoleLoggerLevel);

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
        auto errStatus = newErrStatus;
        auto decision = newDecisionSystem;
        auto support = newSupport(errStatus, decision);
        return support;
    }

    ErrStatus newErrStatus() => new ErrStatus;
    DecisionSystem newDecisionSystem() => new DecisionSystem;

    Support newSupport(ErrStatus errStatus, DecisionSystem decision)
    {
        return new Support(errStatus, decision);
    }

    protected Resourcing createResourcing(Logging logging, Config config, Context context)
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
                "Resourcing path is empty, empty resources manager created");
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
            const mustBeDataDir = context.app.dataDir;
            if (mustBeDataDir.length == 0)
            {
                logging.logger.infof(
                    "Received relative path '%s', but data directory not found", mustBeResDir);
                //WARNING return
                return newResource(logging);
            }

            mustBeResDir = buildPath(mustBeDataDir, mustBeResDir);
            if (!mustBeResDir.exists || !mustBeResDir
                .isDir)
            {
                logging.logger.warning(
                    "Resourcing directory path relative to the data does not exist or is not a directory: ", mustBeResDir);
                //WARNING return
                return newResource(logging);
            }
        }

        auto resources = newResource(logging, mustBeResDir);
        logging.logger.trace(
            "Create resources from directory: ", mustBeResDir);
        return resources;
    }

    LocalResources newLocalResources(Logging logging, string resourcesDir = null)
    {
        return new LocalResources(logging, resourcesDir);
    }

    Resourcing newResource(Logging logging, string resourcesDir = null)
    {
        auto locals = newLocalResources(logging, resourcesDir);
        return new Resourcing(locals);
    }

    Mallocator* newMallocator() => new Mallocator(Allocator.init);

    Allocator* createAllocator(Logging logging, Config config, Context context)
    {
        return cast(Allocator*) newMallocator;
    }

    ArenaAllocator* newArenaAllocator()
    {
        import api.core.utils.allocs.mallocator : initMallocator;
        Allocator alloc;
        initMallocator(&alloc);

        return new ArenaAllocator(alloc);
    }

    ArenaAllocator* createArenaAllocator(Logging logging, Config config, Context context)
    {
        return newArenaAllocator;
    }

    Memory newMemory(Allocator* allocator, ArenaAllocator* arena)
    {
        return new Memory(allocator, arena);
    }

    Memory createMemory(Logging logging, Config config, Context context)
    {
        auto alloc = createAllocator(logging, config, context);
        auto arena = createArenaAllocator(logging, config, context);
        return newMemory(alloc, arena);
    }

    protected Cli createCli(string[] args)
    {
        auto printer = newCliPrinter;
        auto parser = newCliParser(args);
        auto cli = newCli(parser, printer);
        return cli;
    }

    CliPrinter newCliPrinter()
    {
        return new CliPrinter;
    }

    CliParser newCliParser(string[] args)
    {
        return new CliParser(args);
    }

    Cli newCli(CliParser parser, CliPrinter printer)
    {
        return new Cli(parser, printer);
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
        if (!services)
        {
            throw new Exception("Services must not be null");
        }
        _uniServices = services;
    }
}
