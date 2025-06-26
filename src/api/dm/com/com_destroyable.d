module api.dm.com.com_destroyable;

/**
 * Authors: initkfs
 */
interface ComDestroyable
{
nothrow:

    bool isDisposed() pure @safe;
    bool dispose();
}
