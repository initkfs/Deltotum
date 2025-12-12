module api.core.utils.factories;

/**
 * Authors: initkfs
 */

struct ProviderFactory(T)
{
    T delegate() getNew;
    void delegate(scope void delegate(T) onT) getNewScoped;

    this(T delegate() getNewProvider, void delegate(scope void delegate(T)) getNewScopeProvider) pure @safe
    {
        if (!getNewProvider)
        {
            throw new Exception("ProviderFactory must not be null");
        }

        if (!getNewScopeProvider)
        {
            throw new Exception("Scope provider must not be null");
        }
        this.getNew = getNewProvider;
        this.getNewScoped = getNewScopeProvider;
    }
}
