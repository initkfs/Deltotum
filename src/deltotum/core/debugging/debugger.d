module deltotum.core.debugging.debugger;

import deltotum.core.debugging.profiling.profilers.time_profiler : TimeProfiler;
import deltotum.core.debugging.profiling.profilers.memory_profiler : MemoryProfiler;

/**
 * Authors: initkfs
 */

class Debugger
{
    TimeProfiler timeProfiler;
    MemoryProfiler memoryProfiler;

    this(TimeProfiler timeProfiler, MemoryProfiler memoryProfiler)
    {
        this.timeProfiler = timeProfiler;
        this.memoryProfiler = memoryProfiler;
    }
}
