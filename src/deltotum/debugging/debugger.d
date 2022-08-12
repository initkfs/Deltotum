module deltotum.debugging.debugger;

import deltotum.debugging.profiling.profilers.time_profiler : TimeProfiler;
import deltotum.debugging.profiling.profilers.memory_profiler : MemoryProfiler;

/**
 * Authors: initkfs
 */

class Debugger
{
    @property TimeProfiler timeProfiler;
    @property MemoryProfiler memoryProfiler;

    this(TimeProfiler timeProfiler, MemoryProfiler memoryProfiler)
    {
        this.timeProfiler = timeProfiler;
        this.memoryProfiler = memoryProfiler;
    }
}
