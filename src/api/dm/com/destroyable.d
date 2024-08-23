module api.dm.com.destroyable;

/**
 * Authors: initkfs
 */
interface Destroyable
{
nothrow:

    bool isDisposed() pure @safe;
    bool dispose() ;
}
