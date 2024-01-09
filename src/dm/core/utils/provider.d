module dm.core.utils.provider;

enum ToStringExclude;

/**
 * Authors: initkfs
 */
struct Provider(T)
{
    T delegate() get;
    void delegate(scope void delegate(T) onT) getScope;

    this(T delegate() getProvider, void delegate(scope void delegate(T)) getScopeProvider) pure
    {
        import std.exception : enforce;

        this.get = enforce(getProvider, "Provider must not be null");
        this.getScope = enforce(getScopeProvider, "Scope provider must not be null");
    }
}
