module app.core.contexts.null_context;

import app.core.contexts.apps.app_context : AppContext;
import app.core.contexts.platforms.platform_context : PlatformContext;
import app.core.contexts.context : Context;

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
