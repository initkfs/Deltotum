module api.core.utils.sync;

import core.atomic: atomicStore;
import core.sync.mutex : Mutex;

/**
 * Authors: initkfs
 */
struct MutexLock(bool isNothrow = false)
{
    private shared
    {
        Mutex mtx;
    }

    static if (isNothrow)
    {
        this(shared Mutex mtx)  nothrow @safe
        {
            assert(mtx);
            atomicStore(this.mtx, mtx);
            mtx.lock_nothrow;
        }

        ~this()  nothrow @safe
        {
            mtx.unlock_nothrow;
        }
    }
    else
    {
        this(shared Mutex mtx) @safe
        {
            assert(mtx);
            atomicStore(this.mtx, mtx);
            mtx.lock;
        }

        ~this() @safe
        {
            mtx.unlock;
        }
    }
}
