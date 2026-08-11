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
import api.core.validations.validation : Validation;
import api.core.validations.validators.validator : Validator;
import api.core.validations.validators.validator_async : ValidatorAsync, ValidationMessage;
import api.core.contexts.apps.app_context : AppContext;
import api.core.contexts.locators.locator_context : LocatorContext;
import api.core.validations.errors.err_status : ErrStatus;

import CoreEnvKeys = api.core.core_env_keys;

import api.core.loggers.builtins.logger : Logger;
import std.getopt : GetoptResult;

/**
 * Authors: initkfs
 */
class CliApp : SimpleUnit
{
    string appname = "app";
    string appver = "0.1";
    string appid = "app.app";

    string defaultDataDir = "data";
    string defaultConfigsDir = "configs";
    string defaultUserDataDir = "userdata";

    CrashHandler[] crashHandlers;
    ValidatorAsync[] asyncValidators;

    int exitCode;

    private
    {
        UniComponent _uniServices;

        string cliDataDir;
        string cliConfigDir;
        size_t cliStartupDelayMs;

        bool isSilentMode;
        bool isDebugMode;
    }

    bool isStopMainController = true;
    bool isNoEnvConfig;
    bool isNoFileConfig;

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

            buildCreateServices;

            asyncValidators = createAsyncValidators;
        }
        catch (Exception e)
        {
            consumeThrowable(e, false);
            return false;
        }

        return true;
    }

    void buildCreateServices()
    {
        buildCreateServices(uservices);
    }

    void buildCreateServices(UniComponent services)
    {
        services.context = createContext;
        assert(services.hasContext);

        services.configs = createConfiguration(services.context);
        assert(services.hasConfigs);

        services.logging = createLogging(services.context, services.config);
        assert(services.hasLogging);

        assert(services.logging.logger);
        services.validation = createValidation(services.logging, services.config, services
                .context);
        assert(services.hasValidation);

        services.isBuilt = true;
    }

    Validator[] createValidators() => null;

    ValidatorAsync[] createAsyncValidators()
    {
        import std.process : environment;

        ValidatorAsync[] validators;

        auto isValidLog = environment.get(CoreEnvKeys.appLogValidate);
        if (isValidLog)
        {
            import std.conv : to;

            if (isValidLog.to!bool)
            {
                if (!uservices.hasLogging)
                {
                    throw new Exception("Logging is null for validation");
                }

                uservices.logging.logger.onHandler((handler) {
                    import api.core.loggers.builtins.handlers.file_handler : FileHandler;
                    import api.core.validations.validators.validator_async : ValidatorAsync;
                    import api.core.validations.errors.logs.log_file_validator : LogFileValidator;

                    if (auto fileHandler = cast(FileHandler) handler)
                    {
                        import std.file : exists, isFile;

                        auto path = fileHandler.path;
                        if (path.exists && path.isFile)
                        {
                            validators ~= new ValidatorAsync(new LogFileValidator(path));
                        }
                    }
                    return true;
                });
            }
        }

        return validators;
    }

    Validator createConfigValidator(Config config, string[] configKeys)
    {
        import api.core.configs.keyvalues.validators.config_kv_validator : ConfigKValidator;

        return new ConfigKValidator(config, configKeys);
    }

    Validation findAppValidation()
    {
        if (uservices.hasValidation)
        {
            return uservices.validation;
        }
        return null;
    }

    void validate()
    {
        auto validation = findAppValidation;
        if (!validation)
        {
            return;
        }

        validation.validate;

        if (!validation.isValid)
        {
            enum failMessage = "VALIDATION FAIL";
            string message = validation.messages;
            if (uservices.hasLogging && uservices.logging.logger)
            {
                uservices.logging.logger.error(failMessage);
                if (message.length > 0)
                {
                    uservices.logging.logger.error(message);
                }
            }
            else
            {
                import std.stdio : stderr, writeln;

                stderr.writeln(failMessage);
                if (message.length > 0)
                {
                    stderr.writeln(message);
                }
            }

        }
    }

    void validateAsync()
    {
        foreach (v; asyncValidators)
        {
            v.start;
        }
    }

    void checkAsyncValidators(void delegate(ValidationMessage) onMessage)
    {
        if (asyncValidators.length == 0)
        {
            return;
        }

        size_t doneCount;
        foreach (v; asyncValidators)
        {
            v.checkResult;
            if (v.isDone)
            {
                onMessage(v.resultMessage);
                doneCount++;
            }
        }

        if (doneCount == asyncValidators.length)
        {
            asyncValidators = null;
        }
    }

    override void dispose()
    {
        super.dispose;

        if (uservices.hasContext)
        {
            uservices.context.app.exit(exitCode);
        }
        else
        {
            import StdcLib = core.stdc.stdlib;

            StdcLib.exit(1);
        }
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
            if (uservices && uservices.hasLogging)
            {
                uservices.logger.error("Error from application. " ~ ex.toString);
            }
            else
            {
                import std.stdio : stderr;

                stderr.writefln("Error from application: %s", ex);
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

    protected Config createConfig(Context context)
    {
        Config[] configs;

        if (!isNoEnvConfig)
        {
            auto envConfig = createEnvConfig;
            uservices.cli.printer.printIfNotSilent("Create config from environment");
            configs ~= envConfig;
        }

        if (!isNoFileConfig)
        {
            auto fileConfig = createFileConfigs(context);
            configs ~= fileConfig;
        }

        auto config = newConfigAggregator(configs);
        immutable bool isLoad = config.load;

        if (isLoad)
        {
            import std.format : format;

            uservices.cli.printer.printIfNotSilent(format("Load %s configs", configs
                    .length));
        }
        else
        {
            uservices.cli.printer.printIfNotSilent("Configs were not loaded");
        }

        return config;
    }

    Config createEnvConfig()
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
            return new AAConstConfig(null);
        }
    }

    protected Config[] createFileConfigs(Context context)
    {
        Config[] configs;

        import std.path : buildPath, isAbsolute;
        import std.file : isDir, exists;

        string configDir = cliConfigDir;
        if (configDir.length > 0)
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

        if (configDir.length != 0)
        {
            configs ~= configsFromDir(configDir);
        }
        else
        {
            uservices.cli.printer.printIfNotSilent(
                "Path to config directory is empty");
        }

        auto userConfigDir = buildPath(context.app.userDir, defaultConfigsDir);
        if (userConfigDir.exists && userConfigDir.isDir)
        {
            configs ~= configsFromDir(userConfigDir);
        }
        else
        {
            uservices.cli.printer.printIfNotSilent(
                "Check user config, not found: userConfigDir");
        }

        return configs;
    }

    protected Config[] configsFromDir(string configDir)
    {
        import std.file : isDir, exists;

        Config[] configs;

        if (!configDir.exists || !configDir.isDir)
        {
            uservices.cli.printer.printIfNotSilent(
                "Error loading config, directory does not exist or not a directory: " ~ configDir);
            return configs;
        }

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
                "Add config: " ~ configPath.name);
        }

        return configs;
    }

    protected Configuration createConfiguration(Context context)
    {
        auto config = createConfig(context);
        assert(config);
        return newConfiguration(config);
    }

    protected Configuration newConfiguration(Config config) => new Configuration(config);

    protected Logger createLogger(Context context, Config config)
    {
        import api.core.loggers.builtins.base_logger : LogLevel;
        import api.core.loggers.builtins.logger : Logger;
        import api.core.loggers.builtins.handlers.console_handler : ConsoleHandler;
        import api.core.loggers.builtins.handlers.file_handler : FileHandler;
        import api.core.loggers.builtins.handlers.base_log_handler : BaseLogHandler;

        //TODO from config
        auto multiLogger = new Logger;
        multiLogger.level = LogLevel.trace;

        enum consoleLoggerLevel = LogLevel.trace;
        auto consoleLogger = new ConsoleHandler;
        consoleLogger.level = consoleLoggerLevel;

        multiLogger.add(consoleLogger);

        // if (context.app.hasDataDir)
        // {
        //     import std.path : buildPath;
        //     import std.file : exists, mkdir;

        //     auto logDir = buildPath(context.app.dataDir, "logs");
        //     if (!logDir.exists)
        //     {
        //         logDir.mkdir;
        //     }
        //     auto logFile = buildPath(logDir, "log.txt");
        //     auto fileHandler = new FileHandler(logFile);
        //     fileHandler.level = consoleLoggerLevel;
        //     multiLogger.add(fileHandler);
        // }

        auto errHandler = new class BaseLogHandler
        {
            override void output(LogLevel level, const(char)[] message)
            {
                if (level != LogLevel.error)
                {
                    return;
                }
                if (uservices.hasValidation)
                {
                    uservices.validation.errStatus.error(message);
                }
            }
        };

        multiLogger.add(errHandler);

        multiLogger.tracef(
            "Create stdout logging, level '%s'", consoleLoggerLevel);

        return multiLogger;
    }

    protected Logging createLogging(Context context, Config config)
    {
        auto logger = createLogger(context, config);
        assert(logger);
        return newLogging(logger);
    }

    protected Logging newLogging(Logger logger) => new Logging(logger);

    protected Validation createValidation(Logging logging, Config config, Context context)
    {
        auto errStatus = newErrStatus;
        auto support = newValidation(logging.logger, errStatus);
        return support;
    }

    ErrStatus newErrStatus() => new ErrStatus;

    Validation newValidation(Logger logger, ErrStatus errStatus)
    {
        auto validation = new Validation(logger, errStatus);
        return validation;
    }

    protected Cli createCli(string[] args)
    {
        auto printer = newCliPrinter;
        auto parser = newCliParser(args);
        auto cli = newCli(parser, printer);
        return cli;
    }

    CliPrinter newCliPrinter() => new CliPrinter;

    CliParser newCliParser(string[] args) => new CliParser(args);

    Cli newCli(CliParser parser, CliPrinter printer) => new Cli(parser, printer);

    bool isWriteCrashFile()
    {
        import std.process : environment;
        import std.conv : to;

        immutable mustBeIsDisableCrash = environment.get(
            CoreEnvKeys.appCrashNoFile);
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
        import std.process : environment;
        import std.conv : to;

        bool isCreateSyslog = true;
        immutable envValue = environment.get(CoreEnvKeys.appNoCrashSyslog);
        if (envValue !is null && envValue.to!bool)
        {
            isCreateSyslog = false;
        }

        version (linux)
        {
            if (isCreateSyslog)
            {
                import api.core.apps.crashes.syslog_crash_handler : SyslogCrashHandler;

                auto syslogHandler = new SyslogCrashHandler(appname);
                crashHandlers ~= syslogHandler;
            }
        }

        import std.path : dirName, buildPath, isAbsolute;
        import std.file : exists, isDir, isFile, getcwd;
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
