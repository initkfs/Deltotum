module deltotum.core.supports.support;

import deltotum.core.supports.profiling.profilers.time_profiler : TimeProfiler;
import deltotum.core.supports.profiling.profilers.memory_profiler : MemoryProfiler;

/**
 * Authors: initkfs
 */

class Support
{
    TimeProfiler timeProfiler;
    MemoryProfiler memoryProfiler;

    this(TimeProfiler timeProfiler, MemoryProfiler memoryProfiler)
    {
        this.timeProfiler = timeProfiler;
        this.memoryProfiler = memoryProfiler;
    }
}
