module deltotum.core.contexts.context;

import deltotum.core.contexts.apps.app_context : AppContext;

/**
 * Authors: initkfs
 */
class Context
{
    const AppContext appContext;

    this(const AppContext appContext) pure @safe
    {
        this.appContext = appContext;
    }

    this(immutable AppContext appContext) immutable pure @safe
    {
        this.appContext = appContext;
    }
}

unittest
{
    immutable c = new immutable Context(new AppContext);
    assert(is(typeof(c.appContext) : immutable(AppContext)));
}
