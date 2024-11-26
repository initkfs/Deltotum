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
        import std.exception : enforce;

        this.getNew = enforce(getNewProvider, "ProviderFactory must not be null");
        this.getNewScoped = enforce(getNewScopeProvider, "Scope provider must not be null");
    }
}
