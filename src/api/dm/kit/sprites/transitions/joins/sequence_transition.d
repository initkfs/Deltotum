module api.dm.kit.sprites.transitions.joins.sequence_transition;

import api.dm.kit.sprites.transitions.joins.manager_transition : ManagerTransition;
import api.dm.kit.sprites.transitions.transition : Transition;

/**
 * Authors: initkfs
 */
class SequenceTransition : ManagerTransition
{
    Transition first;

    protected
    {
        Transition _last;
    }

    this()
    {
        isInfinite = true;
    }

    override void onFrame()
    {
        bool isStopped = true;
        foreach (tr; transitions)
        {
            if (!tr.isStopped)
            {
                isStopped = false;
                break;
            }
        }

        if (isStopped)
        {
            stop;
        }
    }

    override void run()
    {
        super.run;

        foreach (tr; transitions)
        {
            if (tr.isRunning)
            {
                tr.stop;
            }
        }

        if (first)
        {
            first.run;
        }
    }

    override bool addTransition(Transition tr)
    {
        if (!super.addTransition(tr))
        {
            return false;
        }

        if (!first)
        {
            first = tr;
        }

        if (!_last)
        {
            _last = tr;
            return true;
        }

        _last.onEnd ~= () { tr.run; };

        _last = tr;
        return true;
    }

    override void pause()
    {
        super.pause;
        foreach (tr; transitions)
        {
            if (tr.isRunning)
            {
                tr.pause;
            }
        }
    }

    void resume()
    {
        foreach (tr; transitions)
        {
            if (tr.isPaused)
            {
                tr.run;
            }
        }
    }

    Transition last()
    {
        assert(_last);
        return _last;
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
