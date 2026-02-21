module api.core.supports.support;

import api.core.supports.errors.err_status : ErrStatus;
import api.core.supports.decisions.decision_system: DecisionSystem;

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

    void sleep(size_t valueMs)
    {
        import core.time : dur;
        import core.thread.osthread: Thread;

        Thread.sleep(dur!("msecs")(valueMs));
    }

}
