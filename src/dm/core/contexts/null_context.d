module dm.core.contexts.null_context;

import dm.core.contexts.apps.app_context : AppContext;
import dm.core.contexts.platforms.platform_context : PlatformContext;
import dm.core.contexts.context : Context;

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
