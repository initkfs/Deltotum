module api.dm.kit.sprites.transitions.joins.parallel_transition;

import api.dm.kit.sprites.transitions.joins.manager_transition: ManagerTransition;

/**
 * Authors: initkfs
 */
class ParallelTransition : ManagerTransition
{
    bool isStopOnAnyStopped;

    override void onFrame()
    {
        foreach (tr; transitions)
        {
            if (isStopOnAnyStopped && tr.isStopped)
            {
                stop;
                break;
            }
        }
    }

    override void run()
    {
        super.run;
        foreach (tr; transitions)
        {
            tr.run;
        }
    }

    override void pause()
    {
        super.pause;
        foreach (tr; transitions)
        {
            tr.pause;
        }
    }

    void resume()
    {
        foreach (tr; transitions)
        {
            tr.run;
        }
    }

    override void stop()
    {
        super.stop;
        foreach (tr; transitions)
        {
            if (tr.isRunning)
            {
                tr.stop;
            }
        }
    }
}
