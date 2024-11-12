module api.core.supports.support;

import api.core.supports.errors.err_status : ErrStatus;
import api.core.supports.decisions.decision_system: DecisionSystem;

import std.datetime.stopwatch : StopWatch, AutoStart;

/**
 * Authors: initkfs
 */

class Support
{
    ErrStatus errStatus;
    DecisionSystem decision;

    this(ErrStatus errStatus, DecisionSystem decision) pure @safe
    {
        assert(errStatus);
        this.errStatus = errStatus;

        assert(decision);
        this.decision = decision;
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
        assert(sw.running);
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
