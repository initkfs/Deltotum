module dm.core.supports.profiling.profiler;

/**
 * Authors: initkfs
 */
abstract class Profiler
{
    protected
    {
        string units;
        string name;
    }

    this(string name = "Profiler", string units = "units") pure @safe
    {
        this.name = name;
        this.units = units;
    }

    abstract string report();

    void printReport()
    {
        import std.stdio : writeln;

        immutable result = report;
        writeln(result);
    }

    abstract void createPoint(string name);

    double timestampMsec()
    {
        import std.datetime.systime : Clock;

        //TODO ns
        return Clock.currTime.toUnixTime * 1000;
    }
}
