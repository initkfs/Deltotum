module dm.core.contexts.context;

import dm.core.contexts.apps.app_context : AppContext;
import dm.core.contexts.platforms.platform_context : PlatformContext;

/**
 * Authors: initkfs
 */
class Context
{
    const
    {
        AppContext appContext;
        PlatformContext platformContext;
    }

    this(const AppContext appContext, const PlatformContext platformContext) pure @safe
    {
        this.appContext = appContext;
        this.platformContext = platformContext;
    }

    this(immutable AppContext appContext, immutable PlatformContext platformContext) immutable pure @safe
    {
        this.appContext = appContext;
        this.platformContext = platformContext;
    }
}

unittest
{
    immutable c = new immutable Context(new AppContext, new PlatformContext);
    assert(is(typeof(c.appContext) : immutable(AppContext)));
    assert(is(typeof(c.platformContext) : immutable(PlatformContext)));
}
