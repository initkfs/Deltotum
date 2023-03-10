module deltotum.core.supports.profiling.profilers.memory_profiler;

import deltotum.core.supports.profiling.statistical_values_profiler : StatisticalValuesProfiler;

/**
 * Authors: initkfs
 */
class MemoryProfiler : StatisticalValuesProfiler
{
    this(size_t sampleCount = 100, bool isEnabled = false)
    {
        super(sampleCount, isEnabled);
        name = "Memory profiler";
        units = "bytes";
    }

    override double profilingPointDataValue()
    {
        import core.memory : GC;

        immutable stats = GC.stats;
        immutable allocatedBytes = stats.allocatedInCurrentThread;
        return allocatedBytes;
    }
}
