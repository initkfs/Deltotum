module api.dm.kit.sprites.transitions.transition_compositor;

import api.dm.kit.sprites.transitions.transition : Transition;

/**
 * Authors: initkfs
 */
abstract class TransitionCompositor : Transition
{
    protected
    {
        Transition[] transitions;
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

    override void resume()
    {
        super.resume;
        foreach (tr; transitions)
        {
            tr.resume;
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
        //TODO remove, exists
        if (!tr)
        {
            throw new Exception("Transition must not be null");
        }
        transitions ~= tr;
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
