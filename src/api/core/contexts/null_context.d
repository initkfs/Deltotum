module api.core.contexts.null_context;

import api.core.contexts.apps.app_context : AppContext;
import api.core.contexts.platforms.platform_context : PlatformContext;
import api.core.contexts.context : Context;

/**
 * Authors: initkfs
 */
class NullContext : Context
{
    this() @safe
    {
        super(new AppContext, new PlatformContext);
    }

    this() const @safe
    {
        super(new AppContext, new PlatformContext);
    }

    this() immutable @safe
    {
        super(new AppContext, new PlatformContext);
    }
}
