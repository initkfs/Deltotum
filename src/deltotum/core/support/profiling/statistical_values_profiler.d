module deltotum.core.supports.profiling.statistical_values_profiler;

import deltotum.core.supports.profiling.profiler : Profiler;

/**
 * Authors: initkfs
 */
abstract class StatisticalValuesProfiler : Profiler
{
    private
    {
        size_t sampleCount;
        double[] profilingPointsStartData;
        double[][string] profilingPointsEndData;
    }

    invariant ()
    {
        assert(sampleCount > 0);
    }

    this(size_t sampleCount = 100, bool isEnabled = false)
    {
        super(isEnabled);
        this.sampleCount = sampleCount;

        onProfilingPointCreate = (pointName) {
            profilingPointsStartData ~= profilingPointDataValue;
        };

        onProfilingPointUpdate = (pointName) {
            profilingPointsStartData[currentPointIndex] = profilingPointDataValue;
        };

        onProfilingPointStop = (pointName) {
            immutable startTime = profilingPointsStartData[currentPointIndex];

            if (auto pointDataPtr = pointName in profilingPointsEndData)
            {
                if ((*pointDataPtr).length >= sampleCount)
                {
                    //TODO store?
                    //printReport;
                    //other samples?
                    isEnabled = false;
                    return;
                    //reset;
                }
            }

            immutable pointDiffValue = profilingPointDataValue - startTime;
            profilingPointsEndData[pointName] ~= pointDiffValue;
        };
    }

    abstract double profilingPointDataValue();

    override void reset()
    {
        super.reset;
        profilingPointsStartData = [];
        profilingPointsEndData.clear;
    }

    protected string formatReportValue(double value)
    {
        import std.conv : to;

        return to!string(value);
    }

    override string report()
    {
        import std.array : appender;
        import std.format : format;
        import std.algorithm.sorting : sort;
        import std.algorithm.iteration : mean, sum;
        import std.algorithm.searching : maxElement, minElement;

        auto result = appender!string;
        enum separator = '\n';

        result ~= format("%s (%s):%s", name, units, separator);

        foreach (timePoint; profilingPoints)
        {
            double[] timeInfo = profilingPointsEndData[timePoint];
            assert(timeInfo.length <= sampleCount);

            immutable meanData = timeInfo.mean;
            immutable avgData = timeInfo.length > 0 ? timeInfo.sum / timeInfo.length : 0;
            immutable min = timeInfo.minElement;
            immutable max = timeInfo.maxElement;
            result ~= format("%s. avg: %s, mean: %s, min: %s, max: %s.%s", timePoint, formatReportValue(avgData), formatReportValue(
                    meanData), formatReportValue(min), formatReportValue(max), separator);
        }

        return result.data;
    }
}
