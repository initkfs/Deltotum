module app.dm.kit.sprites.transitions.parallel_transition;

import app.dm.kit.sprites.transitions.transition_compositor: TransitionCompositor;
import app.dm.kit.sprites.transitions.transition : Transition;

/**
 * Authors: initkfs
 */
class ParallelTransition : TransitionCompositor
{
    this()
    {
        super();
        isCycle = true;
    }

    override void onFrame()
    {
        foreach (tr; transitions)
        {
            if (tr.isRunning || tr.isPause)
            {
                return;
            }
        }
        stop;
    }
}
