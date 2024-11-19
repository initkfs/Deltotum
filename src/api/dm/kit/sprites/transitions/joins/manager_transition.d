module api.dm.kit.sprites.transitions.joins.manager_transition;

import api.dm.kit.sprites.transitions.transition : Transition;

/**
 * Authors: initkfs
 */
class ManagerTransition : Transition
{
    protected
    {
        Transition[] transitions;
    }

    override void onFrame()
    {

    }

    bool addTransition(Transition tr)
    {
        if (!tr)
        {
            throw new Exception("Transition must not be null");
        }

        foreach (oldTr; transitions)
        {
            if (oldTr is tr)
            {
                return false;
            }
        }

        if (!tr.isBuilt)
        {
            buildInitCreate(tr);
        }

        if (!tr.parent)
        {
            add(tr);
        }

        transitions ~= tr;
        return true;
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
