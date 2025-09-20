module api.dm.kit.platforms.timers.timing;

import Mem = api.core.utils.mem;

import api.dm.com.platforms.com_platform : ComPlatform;

/**
 * Authors: initkfs
 */
class Timing
{
    ulong delegate() platformTicksProvider;
    enum invalidTimerId = -1;

    private
    {
        TimerParam*[int] timers;

        ComPlatform system;

        struct TimerParam
        {
            int timerId = -1;
            nothrow  int delegate() dg;
            Timing thisPtr;
        }
    }

    private static extern (C)
    {
        uint timer_callback(void* userdata, uint timerID, uint interval) nothrow 
        {
            assert(userdata);
            TimerParam* timerParam = cast(TimerParam*) userdata;
            Timing thisPtr = timerParam.thisPtr;
            assert(thisPtr);
            if (timerParam.timerId != -1)
            {
                return thisPtr.callTimer(timerParam.timerId);
            }

            return interval;
        }
    }

    this(ComPlatform system, ulong delegate() tickProvider) pure @safe
    {
        assert(system);
        this.system = system;

        assert(tickProvider);
        this.platformTicksProvider = tickProvider;
    }

    int add(int intervalMs, int delegate() nothrow  onTimer)
    {
        TimerParam* param = new TimerParam;
        param.dg = onTimer;
        param.thisPtr = this;

        void* paramPtr = cast(void*) param;

        Mem.addRootSafe(paramPtr);

        int timerId;
        if (const err = system.add(timerId, intervalMs, &timer_callback, paramPtr))
        {
            Mem.removeRootSafe(paramPtr);
            throw new Exception(err.toString);

            //return invalidTimerId;
        }
        param.timerId = timerId;
        timers[timerId] = param;
        return timerId;
    }

    protected bool remove(int timerId, TimerParam* timerParamPtr)
    {
        assert(timerId != invalidTimerId);
        assert(timerParamPtr);

        if (const err = system.remove(timerId))
        {
            throw new Exception(err.toString);
            return false;
        }

        Mem.removeRootSafe(cast(void*) timerParamPtr);
        timerParamPtr.dg = null;
        timerParamPtr.thisPtr = null;

        return true;
    }

    bool remove(int timerId)
    {
        if (timerId == invalidTimerId)
        {
            import std.conv : text;

            throw new Exception(text("Invalid timer id received: ", invalidTimerId));
        }

        if (TimerParam** timerParamPtr = timerId in timers)
        {
            if (const isRemoved = remove(timerId, *timerParamPtr))
            {
                timers.remove(timerId);
                return true;
            }
        }

        return false;
    }

    ulong ticksMs()
    {
        assert(platformTicksProvider);
        return platformTicksProvider();
    }

    private int callTimer(int timerId) nothrow 
    {
        if (auto paramPtr = timerId in timers)
        {
            auto dg = (*paramPtr).dg;
            assert(dg);
            return dg();
        }
        return 0;
    }

    void dispose()
    {
        foreach (int timerId, TimerParam* param; timers)
        {
            remove(timerId, param);
        }
        timers = null;
    }

}
