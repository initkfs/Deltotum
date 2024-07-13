module core.supports.support;

import core.supports.errors.err_status : ErrStatus;

import std.datetime.stopwatch : StopWatch, AutoStart;

/**
 * Authors: initkfs
 */

class Support
{
    ErrStatus errStatus;

    this(ErrStatus errStatus)
    {
        this.errStatus = errStatus;
    }

    StopWatch stopwatch(bool isAutoStart = true)
    {
        const autostart = isAutoStart ? AutoStart.yes : AutoStart.no;
        auto sw = StopWatch(autostart);
        sw.start;
        return sw;
    }

    long stopwatch(StopWatch sw)
    {
        sw.stop;
        const long msecs = sw.peek.total!"msecs";
        return msecs;
    }

    void sleep(size_t valueMs)
    {
        import core.time : dur;
        import core.thread.osthread: Thread;

        Thread.sleep(dur!("msecs")(valueMs));
    }

}
