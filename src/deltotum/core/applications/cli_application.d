module deltotum.core.applications.cli_application;

import deltotum.core.applications.components.uni.uni_component : UniComponent;
import deltotum.core.debugging.debugger : Debugger;

import std.logger : Logger;

class CliApplication
{
    UniComponent uniComponentBuilder;

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

    protected Debugger createDebugger()
    {
        import deltotum.core.debugging.profiling.profilers.time_profiler : TimeProfiler;
        import deltotum.core.debugging.profiling.profilers.memory_profiler : MemoryProfiler;

        auto timeProfiler = new TimeProfiler;
        auto memoryProfiler = new MemoryProfiler;

        auto debugger = new Debugger(timeProfiler, memoryProfiler);
        return debugger;
    }

    void initialize()
    {
        import std.experimental.logger : sharedLog;

        uniComponentBuilder = new UniComponent;

        uniComponentBuilder.logger = createLogger;
        //FIXME, dmd v.101: non-shared method `std.logger.multilogger.MultiLogger.insertLogger` is not callable using a `shared` object
        //set new global default logger
        () @trusted { sharedLog = cast(shared) logger; }();

        uniComponentBuilder.debugger = createDebugger;
        logger.trace("Debug service built");
    }

    void build(UniComponent component)
    {
        uniComponentBuilder.build(component);
    }

    abstract void runWait();
    abstract void quit();
    abstract bool update();

    Logger logger()
    {
        return uniComponentBuilder.logger;
    }

    Debugger debugger()
    {
        return uniComponentBuilder.debugger;
    }
}
