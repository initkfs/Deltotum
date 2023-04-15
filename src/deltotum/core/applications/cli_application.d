module deltotum.core.applications.cli_application;

import deltotum.core.applications.crashes.crash_handler : CrashHandler;
import deltotum.core.applications.application_exit : ApplicationExit;
import deltotum.core.applications.components.uni.uni_component : UniComponent;
import deltotum.core.supports.support : Support;
import deltotum.core.configs.config : Config;
import deltotum.core.clis.cli : Cli;
import deltotum.core.contexts.context : Context;
import deltotum.core.resources.resource : Resource;
import deltotum.core.extensions.extension : Extension;

import std.logger : Logger;
import std.typecons : Nullable;
import std.getopt : GetoptResult;

/**
 * Authors: initkfs
 */
class CliApplication
{
    protected
    {
        CrashHandler[] crashHandlers;

        bool isRethrowStartHandlerExceptions = true;
        bool isStopMainController = true;

        string defaultDataDir = "data";
        string defaultConfigsDire = "configs";
        string defaultUserDataDir = "userdata";

        string defaultCrashDirEnvironmentKey = "APP_CRASH_DIR";
        string defaultCrashFileDisableEnvironmentKey = "APP_CRASH_FILE_DISABLE";
    }

    private
    {
        UniComponent _uniServices;

        bool isSilentMode = false;
        bool isDebugMode = false;
        string mustBeDataDirectory;
        string mustBeConfigDir;
    }

    abstract
    {
        void quit();
    }

    ApplicationExit initialize(string[] args)
    {
        _uniServices = new UniComponent;

        auto cli = createCli(args);
        uservices.cli = cli;

        auto cliResult = parseCli(uservices.cli);

        if (cliResult.helpWanted)
        {
            cli.printHelp(cliResult);
            return ApplicationExit(true);
        }

        cli.isSilentMode = isSilentMode;

        if (isDebugMode)
        {
            cli.printIfNotSilent("Debug mode active");
        }

        uservices.context = createContext;
        uservices.config = createConfig(uservices.context);

        uservices.logger = createLogger;
        //FIXME, dmd v.101: non-shared method `std.logger.multilogger.MultiLogger.insertLogger` is not callable using a `shared` object
        //set new global default logger
        import std.logger : sharedLog;

        () @trusted { sharedLog = cast(shared) uservices.logger; }();

        uservices.support = createSupport;
        uservices.logger.trace("Support service built");

        uservices.resource = createResource(uservices.config, uservices.context);
        uservices.logger.trace("Resources service built");

        uservices.extension = createExtension(uservices.logger, uservices.config, uservices.context);
        uservices.logger.trace("Extension service built");

        uservices.isBuilt = true;

        return ApplicationExit();
    }

    protected void consumeThrowable(Throwable ex, bool isReThrow = true)
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
            if (uservices.logger !is null)
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
            if (uservices.logger !is null)
            {
                uservices.logger.errorf("Error from application. %s", ex);
            }

            if (isReThrow)
            {
                throw ex;
            }
        }
    }

    GetoptResult parseCli(Cli cliManager)
    {
        import std.format : format;
        import std.uni : toLower;

        GetoptResult cliResult = cliManager.parse("s|silent",
            "Silent mode, less information in program output.", &isSilentMode,
            "g|debug", "Debug mode",
            &isDebugMode, format!"%s|%s"(defaultDataDir[0].toLower,
                defaultDataDir), "Application data directory.",
            &mustBeDataDirectory, "c|configdir", "Config directory", &mustBeConfigDir);

        return cliResult;
    }

    protected Context createContext()
    in (uservices.cli !is null)
    {

        import std.path : dirName, buildPath, isAbsolute;
        import std.file : exists, isDir, isFile, getcwd;

        const currentDir = getcwd;
        uservices.cli.printIfNotSilent("Current working directory: " ~ currentDir);

        string dataDirectory;
        if (mustBeDataDirectory)
        {
            dataDirectory = mustBeDataDirectory;
            uservices.cli.printIfNotSilent("Received data directory from cli: " ~ dataDirectory);
            if (!dataDirectory.isAbsolute)
            {
                dataDirectory = buildPath(currentDir, dataDirectory);
                uservices.cli.printIfNotSilent(
                    "Convert data directory from cli to absolute path: " ~ dataDirectory);
            }
        }
        else
        {
            const relDataDir = buildPath(currentDir, defaultDataDir);
            if (relDataDir.exists && relDataDir.isDir)
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

        import deltotum.core.contexts.apps.app_context : AppContext;

        const appContext = new AppContext(currentDir, dataDirectory, userDir, isDebugMode, isSilentMode);
        auto context = new Context(appContext);
        return context;
    }

    protected Config createConfig(Context context)
    {
        import std.path : buildPath, isAbsolute;

        string configDir = mustBeConfigDir;
        if (configDir)
        {
            uservices.cli.printIfNotSilent("Received config directory from cli: " ~ configDir);
            if (!configDir.isAbsolute)
            {
                const mustBeDataDir = context.appContext.dataDir;
                if (mustBeDataDir.isNull)
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
            const mustBeDataDir = context.appContext.dataDir;
            if (!mustBeDataDir.isNull)
            {
                configDir = buildPath(mustBeDataDir.get, defaultConfigsDire);
                uservices.cli.printIfNotSilent(
                    "Default config directory will be used: " ~ configDir);
            }
            else
            {
                uservices.cli.printIfNotSilent(
                    "Data directory not found so default config path cannot be built");
            }

        }

        if (configDir.length == 0)
        {
            uservices.cli.printIfNotSilent("Path to config directory is empty");
            //TODO Environment config
            import deltotum.core.configs.config_aggregator : ConfigAggregator;

            Config[] configs;
            auto config = new ConfigAggregator(configs);
            config.load;
            return config;
        }

        import std.file : isDir, exists;

        if (!configDir.exists || !configDir.isDir)
        {
            throw new Exception("Config directory does not exist or not a directory: " ~ configDir);
        }

        import deltotum.core.configs.json.json_config : JsonConfig;
        import deltotum.core.configs.config_aggregator : ConfigAggregator;
        import std.file : dirEntries, SpanMode;
        import std.algorithm.iteration : filter;
        import std.algorithm.searching : endsWith;

        Config[] configs;

        //TODO factory by file extension
        foreach (configPath; dirEntries(configDir, SpanMode.depth).filter!(f => f.isFile && f.name.endsWith(
                ".json")))
        {
            //TODO check for duplicate keys
            configs ~= new JsonConfig(configPath);
        }
        auto config = new ConfigAggregator(configs);
        config.load;

        import std.format : format;

        uservices.cli.printIfNotSilent(format("Load %s configs from %s", configs.length, configDir));
        return config;
    }

    protected Logger createLogger()
    {
        import std.logger : MultiLogger, FileLogger, LogLevel;

        auto multiLogger = new MultiLogger(LogLevel.trace);
        import std.stdio : stdout;

        enum consoleLoggerLevel = LogLevel.trace;
        auto consoleLogger = new FileLogger(stdout, consoleLoggerLevel);
        const string consoleLoggerName = "stdout_logger";
        multiLogger.insertLogger(consoleLoggerName, consoleLogger);

        multiLogger.tracef("Create stdout logger, name '%s', level '%s'",
            consoleLoggerName, consoleLoggerLevel);

        return multiLogger;
    }

    protected Support createSupport()
    {
        import deltotum.core.supports.profiling.profilers.time_profiler : TimeProfiler;
        import deltotum.core.supports.profiling.profilers.memory_profiler : MemoryProfiler;

        auto timeProfiler = new TimeProfiler;
        auto memoryProfiler = new MemoryProfiler;

        auto support = new Support(timeProfiler, memoryProfiler);
        return support;
    }

    protected Resource createResource(Config config, Context context)
    {
        import std.path : buildPath;

        const mustBeDataDir = context.appContext.dataDir;
        if (mustBeDataDir.isNull)
        {
            auto resource = new Resource;
            return resource;
        }

        string resourceDir = buildPath(mustBeDataDir.get, "resources");
        auto resource = new Resource(resourceDir);
        return resource;
    }

    protected Extension createExtension(Logger logger, Config config, Context context)
    {
        import deltotum.core.extensions.lua.lua_extension_collector : LuaExtensionCollector;

        //TODO from config;
        import std.path : buildPath;
        auto mustBeDataDir = context.appContext.dataDir;
        if(mustBeDataDir.isNull){
            //TODO or return Nullable?
            throw new Exception("Data directory not found");
        }

        const extDir = buildPath(mustBeDataDir.get, "extensions");
        auto collector = new LuaExtensionCollector(logger, config, context, extDir);
        collector.initialize;
        //FIXME lazy load
        collector.load;
        return collector;
    }

    protected Cli createCli(string[] args)
    {
        import deltotum.core.clis.printers.cli_printer : CliPrinter;

        auto printer = new CliPrinter;
        auto cli = new Cli(args, printer);
        return cli;
    }

    protected void createCrashHandlers(string[] args)
    {
        import std.path : dirName, buildPath, isAbsolute;
        import std.file : exists, isDir, isFile, getcwd;
        import std.process : environment;
        import std.format : format;

        string crashDir = getcwd;

        immutable mustBeCrashDir = environment.get(defaultCrashDirEnvironmentKey);
        if (mustBeCrashDir)
        {
            if (!mustBeCrashDir.exists || !mustBeCrashDir.isDir)
            {
                throw new Exception(format(
                        "Crash directory from environment key %s does not exist or not a directory: %s",
                        defaultCrashDirEnvironmentKey, mustBeCrashDir));
            }
            crashDir = mustBeCrashDir;
        }

        import deltotum.core.applications.crashes.file_crash_handler : FileCrashHandler;

        crashHandlers ~= new FileCrashHandler(crashDir);
    }

    void build(UniComponent component)
    {
        uservices.build(component);
    }

    UniComponent uservices() @nogc nothrow pure @safe
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
