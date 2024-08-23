module api.dm.kit.sprites.transitions.parallel_transition;

import api.dm.kit.sprites.transitions.transition_compositor: TransitionCompositor;
import api.dm.kit.sprites.transitions.transition : Transition;

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
