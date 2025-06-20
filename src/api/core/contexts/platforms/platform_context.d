module api.core.contexts.platforms.platform_context;

/**
 * Authors: initkfs
 */
class PlatformContext
{
    void requestGC() const @safe
    {
        import core.memory : GC;

        GC.collect;
        GC.minimize;
    }

    void sleep(size_t delayMs) const
    {
        import std.datetime : dur;
        import core.thread : Thread;

        Thread.sleep(dur!("msecs")(delayMs));
    }

    immutable(PlatformContext) idup()
    {
        return new immutable PlatformContext;
    }

}
