module app.core.contexts.context;

import app.core.contexts.apps.app_context : AppContext;
import app.core.contexts.platforms.platform_context : PlatformContext;

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

    immutable(Context) idup() immutable
    {
        assert(appContext);
        assert(platformContext);

        return new immutable Context(appContext.idup, platformContext.idup);
    }
}

unittest
{
    immutable c = new immutable Context(new AppContext, new PlatformContext);
    assert(is(typeof(c.appContext) : immutable(AppContext)));
    assert(is(typeof(c.platformContext) : immutable(PlatformContext)));
}
