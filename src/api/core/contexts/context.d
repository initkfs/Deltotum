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
    AppContext app;
    PlatformContext platform;
    LocatorContext locator;

    this(AppContext app, PlatformContext platform, LocatorContext locator) pure @safe
    {
        assert(app);
        assert(platform);
        assert(locator);

        this.app = app;
        this.platform = platform;
        this.locator = locator;
    }

    this(immutable AppContext app, immutable PlatformContext platform, immutable LocatorContext locator) immutable pure @safe
    {
        assert(app);
        assert(platform);
        assert(locator);

        this.app = app;
        this.platform = platform;
        this.locator = locator;
    }

    immutable(Context) idup()
    {
        return new immutable Context(app.idup, platform.idup, locator.idup);
    }
}

unittest
{
    immutable c = new immutable Context(new AppContext, new PlatformContext, new LocatorContext);
    assert(is(typeof(c.app) : immutable(AppContext)));
    assert(is(typeof(c.platform) : immutable(PlatformContext)));
    assert(is(typeof(c.locator) : immutable(LocatorContext)));
}
