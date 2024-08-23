module api.core.contexts.null_context;

import api.core.contexts.apps.app_context : AppContext;
import api.core.contexts.platforms.platform_context : PlatformContext;
import api.core.contexts.context : Context;

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
