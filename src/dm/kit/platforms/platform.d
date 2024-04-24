module dm.kit.platforms.platform;

import dm.com.platforms.com_system : ComSystem;
import dm.core.components.units.services.application_unit : ApplicationUnit;
import dm.core.components.units.services.loggable_unit : LoggableUnit;
import dm.core.contexts.context : Context;
import dm.core.configs.config : Config;

import Mem = dm.core.utils.mem;

import std.logger.core : Logger;

/**
 * Authors: initkfs
 */
class Platform : ApplicationUnit
{
    protected
    {
        ComSystem system;
    }

    ulong delegate() platformTicksProvider;
    enum invalidTimerId = -1;

    private
    {
        TimerParam*[int] timers;

        struct TimerParam
        {
            int timerId = -1;
            int delegate() dg;
            Platform thisPtr;
        }
    }

    this(ComSystem system, Logger logger, Config config, Context context, ulong delegate() tickProvider) pure @safe
    {
        super(logger, config, context);

        assert(system);
        this.system = system;
        assert(tickProvider);
        this.platformTicksProvider = tickProvider;
    }

    void openURL(string url, bool isThrowOnOpen = false, bool isThrowOnInvalidUrl = false)
    {
        import std.uri : uriLength;

        immutable len = url.uriLength;
        if (len <= 0)
        {
            immutable errMessage = "Invalid URL received: " ~ url;
            if (isThrowOnInvalidUrl)
            {
                throw new Exception(errMessage);
            }
            else
            {
                logger.error(errMessage);
                return;
            }
        }

        if (const err = system.openURL(url))
        {
            immutable message = "Error opening url: " ~ err.toString;
            if (isThrowOnOpen)
            {
                throw new Exception(message);
            }

            logger.error(message);
        }
    }

    private static extern (C)
    {
        uint timer_callback(uint interval, void* param) nothrow
        {
            assert(param);
            TimerParam* timerParam = cast(TimerParam*) param;
            Platform thisPtr = timerParam.thisPtr;
            assert(thisPtr);
            if (timerParam.timerId != -1)
            {
                return thisPtr.callTimer(timerParam.timerId);
            }

            return interval;
        }
    }

    private int callTimer(int timerId) nothrow
    {
        try
        {
            if (auto paramPtr = timerId in timers)
            {
                auto dg = (*paramPtr).dg;
                assert(dg);
                return dg();
            }
        }
        catch (Exception e)
        {
            try
            {
                assert(logger);
                logger.error(e);

            }
            catch (Exception e)
            {
                throw new Error("Logging error from timer", e);
            }
        }
        return 0;
    }

    int addTimerMT(int intervalMs, int delegate() onTimer)
    {
        TimerParam* param = new TimerParam;
        param.dg = onTimer;
        param.thisPtr = this;

        void* paramPtr = cast(void*) param;

        Mem.addRootSafe(paramPtr);

        int timerId;
        if (const err = system.addTimerMT(timerId, intervalMs, &timer_callback, paramPtr))
        {
            logger.error(err);
            Mem.removeRootSafe(paramPtr);
            return invalidTimerId;
        }
        param.timerId = timerId;
        timers[timerId] = param;
        return timerId;
    }

    protected bool removeTimer(int timerId, TimerParam* timerParamPtr)
    {
        assert(timerId != invalidTimerId);
        assert(timerParamPtr);

        if (const err = system.removeTimer(timerId))
        {
            logger.error(err);
            return false;
        }

        Mem.removeRootSafe(cast(void*) timerParamPtr);
        timerParamPtr.dg = null;
        timerParamPtr.thisPtr = null;

        return true;
    }

    bool removeTimer(int timerId)
    {
        if (timerId == invalidTimerId)
        {
            logger.error("Invalid timer id received: ", invalidTimerId);
            return false;
        }

        if (TimerParam** timerParamPtr = timerId in timers)
        {
            if (const isRemoved = removeTimer(timerId, *timerParamPtr))
            {
                timers.remove(timerId);
                return true;
            }
        }

        return false;
    }

    ulong ticks()
    {
        assert(platformTicksProvider);
        return platformTicksProvider();
    }

    override void dispose()
    {
        super.dispose;

        foreach (int timerId, TimerParam* param; timers)
        {
            removeTimer(timerId, param);
        }
        timers = null;
    }
}
