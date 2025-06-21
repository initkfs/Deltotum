module api.core.contexts.null_context;

import api.core.contexts.apps.app_context : AppContext;
import api.core.contexts.platforms.platform_context : PlatformContext;
import api.core.contexts.context : Context;
import api.core.contexts.locators.locator_context: LocatorContext;

/**
 * Authors: initkfs
 */
class NullContext : Context
{
    this() @safe
    {
        super(new AppContext, new PlatformContext, new LocatorContext);
    }

    this() const @safe
    {
        super(new AppContext, new PlatformContext, new const LocatorContext);
    }

    this() immutable @safe
    {
        super(new immutable AppContext, new immutable PlatformContext, new immutable LocatorContext);
    }
}
