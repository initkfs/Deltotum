module dm.core.supports.support;

import dm.core.supports.profiling.profilers.tm_profiler : TMProfiler;

/**
 * Authors: initkfs
 */

class Support
{
    TMProfiler tmProfiler;

    this(TMProfiler tmProfiler)
    {
        this.tmProfiler = tmProfiler;
    }

    void printReport()
    {
        tmProfiler.printReport;
    }
}
