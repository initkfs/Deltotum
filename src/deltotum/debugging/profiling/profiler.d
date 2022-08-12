module deltotum.debugging.profiling.profiler;

/**
 * Authors: initkfs
 */
abstract class Profiler
{
    @property bool isEnabled;

    @property void delegate(string) onProfilingPointCreate;
    @property void delegate(string) onProfilingPointUpdate;
    @property void delegate(string) onProfilingPointStop;

    protected
    {
        @property size_t currentPointIndex;
        @property string[] profilingPoints = [];

        @property string units = "units";
        @property string name = "Profiler";
    }

    invariant
    {
        assert(currentPointIndex <= profilingPoints.length);
        assert(units.length > 0);
        assert(name.length > 0);
    }

    this(bool isEnabled = false)
    {
        this.isEnabled = isEnabled;
    }

    abstract string report();

    void printReport()
    {
        import std.stdio : writeln;

        immutable result = report;
        writeln(result);
    }

    void start(string profilingPointName = "Profiling point")
    {
        //TODO invariants start == end calls.
        if (!isEnabled)
        {
            return;
        }

        import std.string : strip;

        immutable pointName = profilingPointName.strip;
        if (pointName.length == 0)
        {
            throw new Exception("Profiling point name must not be empty");
        }

        if (currentPointIndex == profilingPoints.length)
        {
            profilingPoints ~= pointName;
            if (onProfilingPointCreate !is null)
            {
                onProfilingPointCreate(pointName);
            }
        }
        else
        {
            if (onProfilingPointUpdate !is null)
            {
                //assert with canFind?
                onProfilingPointUpdate(pointName);
            }
        }

        currentPointIndex++;
    }

    void stop()
    {
        if (!isEnabled || profilingPoints.length == 0)
        {
            return;
        }

        if (currentPointIndex == 0)
        {
            throw new Exception("Can't stop profiling, current profiling point index is zero");
        }

        //TODO invariant stop == start
        currentPointIndex--;

        if (onProfilingPointStop !is null)
        {
            immutable pointName = currentProfilingPoint;
            onProfilingPointStop(pointName);
        }
    }

    string currentProfilingPoint()
    {
        if (profilingPoints.length == 0)
        {
            throw new Exception("Unable to get profiling point name: no points found");
        }

        if (currentPointIndex >= profilingPoints.length)
        {
            import std.format : format;

            throw new Exception(format(
                    "Unable to get profiling point name: the current index %s exceeds the number of profiling points %s", currentPointIndex, profilingPoints
                    .length));
        }

        immutable pointName = profilingPoints[currentPointIndex];
        return pointName;
    }

    void reset()
    {
        currentPointIndex = 0;
        profilingPoints = [];
    }
}
