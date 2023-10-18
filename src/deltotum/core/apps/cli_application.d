module deltotum.core.apps.cli_application;

import deltotum.core.apps.units.simple_unit : SimpleUnit;
import deltotum.core.apps.crashes.crash_handler : CrashHandler;
import deltotum.core.apps.application_exit : ApplicationExit;
import deltotum.core.apps.uni.uni_component : UniComponent;
import deltotum.core.supports.support : Support;
import deltotum.core.configs.config : Config;
import deltotum.core.clis.cli : Cli;
import deltotum.core.contexts.context : Context;
import deltotum.core.resources.resource : Resource;
import deltotum.core.extensions.extension : Extension;
import deltotum.core.apps.caps.cap_core : CapCore;

import std.logger : Logger;
import std.typecons : Nullable;
import std.getopt : GetoptResult;

/**
 * Authors: initkfs
 */
class CliApplication : SimpleUnit
{
    bool isStopMainController = true;

    string defaultDataDir = "data";
    string defaultConfigsDir = "configs";
    string defaultUserDataDir = "userdata";

    string envCrashDirKey = "APP_CRASH_DIR";
    string envCrashFileDisableKey = "APP_CRASH_FILE_DISABLE";

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

    abstract
    {
        void quit();
    }

    ApplicationExit initialize(string[] args)
    {
        super.initialize;

        _uniServices = newUniServices;

        uservices.capCore = newCapCore;

        auto cli = createCli(args);
        uservices.cli = cli;

        auto cliResult = parseCli(uservices.cli);

        cli.isSilentMode = isSilentMode;

        if (cliResult.helpWanted)
        {
            cli.printHelp(cliResult);
            return ApplicationExit(true);
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

        uservices.context = createContext;
        uservices.config = createConfig(uservices.context);

        uservices.logger = createLogger;
        //FIXME, dmd v.101: non-shared method `std.logger.multilogger.MultiLogger.insertLogger` is not callable using a `shared` object
        //set new global default logger
        import std.logger : sharedLog;

        () @trusted { sharedLog = cast(shared) uservices.logger; }();

        uservices.support = createSupport;
        uservices.logger.trace("Support service built");

        uservices.resource = createResource(uservices.logger, uservices.config, uservices.context);
        uservices.logger.trace("Resources service built");

        uservices.ext = createExtension(uservices.logger, uservices.config, uservices.context);
        uservices.logger.trace("Extension service built");

        uservices.isBuilt = true;

        return ApplicationExit();
    }

    UniComponent newUniServices()
    {
        return new UniComponent;
    }

    CapCore newCapCore()
    {
        return new CapCore;
    }

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

            if (isRethrow)
            {
                throw ex;
            }
        }
    }

    GetoptResult parseCli(Cli cliManager)
    {
        import std.format : format;
        import std.uni : toLower;
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
    in (uservices.cli !is null)
    {

        import std.path : dirName, buildPath, isAbsolute;
        import std.file : exists, isDir, isFile;

        const string curDir = currentDir;
        uservices.cli.printIfNotSilent("Current working directory: " ~ curDir);

        string dataDirectory;
        if (cliDataDir)
        {
            dataDirectory = cliDataDir;
            uservices.cli.printIfNotSilent("Received data directory from cli: " ~ dataDirectory);
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

        const appContext = new AppContext(curDir, dataDirectory, userDir, isDebugMode, isSilentMode);
        auto context = new Context(appContext);
        return context;
    }

    protected Config newConfigFromFile(string configFile)
    {
        import std.algorithm.searching : startsWith;
        import std.path : extension;

        import deltotum.core.configs.properties.property_config : PropertyConfig;

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

        throw new Exception("Not supported config: " ~ configFile);
    }

    protected Config newConfigAggregator(Config[] forConfigs)
    {
        import deltotum.core.configs.config_aggregator : ConfigAggregator;

        return new ConfigAggregator(forConfigs);
    }

    protected Config newEnvConfig()
    {
        import deltotum.core.configs.environments.env_config : EnvConfig;

        return new EnvConfig;
    }

    protected Config createConfig(Context context)
    {
        import std.path : buildPath, isAbsolute;

        string configDir = cliConfigDir;
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
                configDir = buildPath(mustBeDataDir.get, defaultConfigsDir);
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

            Config[] configs;
            auto config = newConfigAggregator(configs);
            config.load;
            return config;
        }

        import std.file : isDir, exists;

        if (!configDir.exists || !configDir.isDir)
        {
            throw new Exception(
                "Config directory does not exist or not a directory: " ~ configDir);
        }

        import deltotum.core.configs.properties.property_config : PropertyConfig;
        import deltotum.core.configs.config_aggregator : ConfigAggregator;
        import std.file : dirEntries, SpanMode;
        import std.algorithm.iteration : filter;
        import std.algorithm.searching : endsWith;

        Config[] configs;

        //TODO is hidden
        foreach (configPath; dirEntries(configDir, SpanMode.depth).filter!(f => f.isFile))
        {
            configs ~= newConfigFromFile(configPath.name);
        }

        configs ~= newEnvConfig;

        //TODO check for duplicate keys
        auto config = newConfigAggregator(configs);
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

    protected Resource createResource(Logger logger, Config config, Context context, string resourceDirPath = "resources")
    {
        import std.path : buildPath, isAbsolute;
        import std.file : exists, isDir;

        string mustBeResDir = resourceDirPath;
        if (mustBeResDir.isAbsolute)
        {
            if (!mustBeResDir.exists || !mustBeResDir.isDir)
            {
                uservices.logger.error(
                    "Absolute resources directory path does not exist or not a directory: " ~ mustBeResDir);
                //WARNING return
                return new Resource(logger);
            }
        }
        else
        {
            const mustBeDataDir = context.appContext.dataDir;
            if (mustBeDataDir.isNull)
            {
                uservices.logger.errorf(
                    "Received relative resource path %s, but data directory not found");
                //WARNING return
                return new Resource(logger);
            }

            mustBeResDir = buildPath(mustBeDataDir.get, mustBeResDir);
            if (!mustBeResDir.exists || !mustBeResDir.isDir)
            {
                uservices.logger.error(
                    "Resource directory path relative to the data does not exist or is not a directory: ", mustBeResDir);
                //WARNING return
                return new Resource(logger);
            }
        }

        auto resource = new Resource(logger, mustBeResDir);
        uservices.logger.trace("Create resources from directory: ", mustBeResDir);
        return resource;
    }

    protected Cli createCli(string[] args)
    {
        import deltotum.core.clis.printers.cli_printer : CliPrinter;

        auto printer = new CliPrinter;
        auto cli = new Cli(args, printer);
        return cli;
    }

    protected Extension createExtension(Logger logger, Config config, Context context)
    {
        auto extension = new Extension;

        extension.initialize;
        extension.create;
        extension.run;

        return extension;
    }

    protected void createCrashHandlers(string[] args)
    {
        import std.path : dirName, buildPath, isAbsolute;
        import std.file : exists, isDir, isFile, getcwd;
        import std.process : environment;
        import std.format : format;

        string crashDir = getcwd;

        immutable mustBeCrashDir = environment.get(envCrashDirKey);
        if (mustBeCrashDir)
        {
            if (!mustBeCrashDir.exists || !mustBeCrashDir.isDir)
            {
                throw new Exception(format(
                        "Crash directory from environment key %s does not exist or not a directory: %s",
                        envCrashDirKey, mustBeCrashDir));
            }
            crashDir = mustBeCrashDir;
        }

        import deltotum.core.apps.crashes.file_crash_handler : FileCrashHandler;

        crashHandlers ~= new FileCrashHandler(crashDir);
    }

    string currentDir()
    {
        import std.file : getcwd;

        return getcwd;
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
