module dm.core.supports.profiling.profilers.tm_profiler;

import dm.core.supports.profiling.profiler : Profiler;

/**
 * Authors: initkfs
 */
class TMProfiler : Profiler
{
    protected
    {
        string[] pointsNames;
        double[2][] pointsData;
    }

    invariant
    {
        assert(pointsNames.length == pointsData.length);
    }

    this(size_t reserved = 5)
    {
        pointsNames.reserve(reserved);
        pointsData.reserve(reserved);
    }

    override void createPoint(string name = "New point")
    {
        import core.memory : GC;

        immutable timestamp = timestampMsec();

        immutable stats = GC.stats;
        immutable allocatedBytes = stats.allocatedInCurrentThread;

        pointsNames ~= name;
        pointsData ~= [timestamp, allocatedBytes];
    }

    override string report()
    {
        import std.array : appender;
        import std.conv : to;

        auto result = appender!string;
        enum separator = '\n';

        foreach (i, name; pointsNames)
        {
            double[2] pointsValues = pointsData[i];
            result ~= name;
            result ~= " ";
            result ~= pointsValues.to!string;
            if (i > 0)
            {
                auto prevData = pointsData[i - 1];
                result ~= ", ";
                result ~= (pointsValues[1] - prevData[1]).to!string;
            }
            result ~= separator;
        }

        return result.data;
    }
}
