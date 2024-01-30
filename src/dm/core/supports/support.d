module dm.core.supports.support;

import dm.core.supports.profiling.profilers.tm_profiler : TMProfiler;
import dm.core.supports.errors.err_status: ErrStatus;

/**
 * Authors: initkfs
 */

class Support
{
    TMProfiler tmProfiler;
    ErrStatus errStatus;

    this(TMProfiler tmProfiler, ErrStatus errStatus)
    {
        this.tmProfiler = tmProfiler;
        this.errStatus = errStatus;
    }

    void printReport()
    {
        tmProfiler.printReport;
    }
}
