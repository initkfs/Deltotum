module core.contexts.null_context;

import core.contexts.apps.app_context : AppContext;
import core.contexts.platforms.platform_context : PlatformContext;
import core.contexts.context : Context;

/**
 * Authors: initkfs
 */
class NullContext : Context
{
    this() immutable pure @safe
    {
        super(new AppContext, new PlatformContext);
    }
}
