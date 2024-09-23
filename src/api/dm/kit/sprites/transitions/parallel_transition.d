module api.dm.kit.sprites.transitions.parallel_transition;

import api.dm.kit.sprites.transitions.transition : Transition;

/**
 * Authors: initkfs
 */
class ParallelTransition : Transition
{
    bool isStopOnAnyStopped;

    protected
    {
        Transition[] transitions;
    }

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

    void addTransition(Transition tr)
    {
        if (!tr)
        {
            throw new Exception("Transition must not be null");
        }
        transitions ~= tr;
    }

    bool removeTransition(Transition tr)
    {
        if (!tr)
        {
            throw new Exception("Transition must not be null");
        }

        import api.core.utils.arrays : drop;

        return drop(transitions, tr);
    }

    bool hasTransition(Transition tr)
    {
        foreach (t; transitions)
        {
            if (tr is t)
            {
                return true;
            }
        }
        return false;
    }

    void clearTransitions()
    {
        transitions = null;
    }

    override void dispose()
    {
        super.dispose;
        clearTransitions;
    }
}
