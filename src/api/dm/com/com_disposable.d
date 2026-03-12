module api.dm.com.com_disposable;

/**
 * Authors: initkfs
 */
interface ComDisposable
{
nothrow:

    bool isDisposed() pure @safe;
    bool dispose();
}
