module dm.com.lifecycles.destroyable;

/**
 * Authors: initkfs
 */
interface Destroyable
{
    bool isDisposed() @nogc nothrow pure @safe;
    bool dispose() @nogc nothrow;
}
