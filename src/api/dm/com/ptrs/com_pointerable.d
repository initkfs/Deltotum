module api.dm.com.ptrs.com_pointerable;

import api.dm.com.com_disposable: ComDisposable;
import api.dm.com.ptrs.com_native_ptr: ComNativePtr;
import api.dm.com.com_result : ComResult;

/**
 * Authors: initkfs
 */
interface ComPointerable : ComDisposable
{
    void* rawPtr() nothrow;
    ComResult nativePtr(out ComNativePtr ptr) nothrow;

    bool hasPtr() nothrow pure @safe;
}
