module api.core.contexts.context;

import api.core.components.component_service : ComponentService;
import api.core.contexts.apps.app_context : AppContext;
import api.core.contexts.platforms.platform_context : PlatformContext;
import api.core.contexts.locators.locator_context : LocatorContext;

/**
 * Authors: initkfs
 */
class Context : ComponentService
{
    AppContext appContext;
    PlatformContext platformContext;
    LocatorContext locatorContext;

    this(AppContext appContext, PlatformContext platformContext, LocatorContext locatorContext) pure @safe
    {
        assert(appContext);
        assert(platformContext);
        assert(locatorContext);

        this.appContext = appContext;
        this.platformContext = platformContext;
        this.locatorContext = locatorContext;
    }

    this(immutable AppContext appContext, immutable PlatformContext platformContext, immutable LocatorContext locatorContext) immutable pure @safe
    {
        assert(appContext);
        assert(platformContext);
        assert(locatorContext);

        this.appContext = appContext;
        this.platformContext = platformContext;
        this.locatorContext = locatorContext;
    }

    immutable(Context) idup()
    {
        return new immutable Context(appContext.idup, platformContext.idup, locatorContext.idup);
    }
}

unittest
{
    immutable c = new immutable Context(new AppContext, new PlatformContext, new LocatorContext);
    assert(is(typeof(c.appContext) : immutable(AppContext)));
    assert(is(typeof(c.platformContext) : immutable(PlatformContext)));
    assert(is(typeof(c.locatorContext) : immutable(LocatorContext)));
}
