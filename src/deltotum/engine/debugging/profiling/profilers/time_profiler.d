module deltotum.engine.debugging.profiling.profilers.time_profiler;

import deltotum.engine.debugging.profiling.statistical_values_profiler : StatisticalValuesProfiler;

/**
 * Authors: initkfs
 */
class TimeProfiler : StatisticalValuesProfiler
{
    this(size_t sampleCount = 100, bool isEnabled = false)
    {
        super(sampleCount, isEnabled);
        name = "Time profiler";
        units = "ms";
    }

    override double profilingPointDataValue()
    {
        version (Posix)
        {
            import core.sys.posix.time;

            timespec time;
            const int timeResult = clock_gettime(CLOCK_MONOTONIC, &time);
            if (timeResult < 0)
            {
                //TODO errno
                throw new Exception("Unable to get current time");
            }

            return time.tv_sec * 1000 + time.tv_nsec * 0.000001;
        }
        else
        {
            import std.datetime.systime : SysTime, Clock, stdTimeToUnixTime, unixTimeToStdTime;

            return (Clock.currTime() - SysTime(unixTimeToStdTime(0)))
                .total!"msecs";
            return 0;
        }
    }
}
