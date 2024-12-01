module api.dm.kit.tweens.joins.sequence_tween;

import api.dm.kit.tweens.joins.tween_manager : TweenManager;
import api.dm.kit.tweens.tween : Tween;

/**
 * Authors: initkfs
 */
class SequenceTween : TweenManager
{
    Tween first;

    protected
    {
        Tween _last;
    }

    this()
    {
        isInfinite = true;
    }

    override void onFrame()
    {
        bool isStopped = true;
        foreach (tr; tweens)
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

        foreach (tr; tweens)
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

    override bool addTween(Tween tr)
    {
        if (!super.addTween(tr))
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
        foreach (tr; tweens)
        {
            if (tr.isRunning)
            {
                tr.pause;
            }
        }
    }

    void resume()
    {
        foreach (tr; tweens)
        {
            if (tr.isPaused)
            {
                tr.run;
            }
        }
    }

    Tween last()
    {
        assert(_last);
        return _last;
    }

    override void stop()
    {
        super.stop;
        foreach (tr; tweens)
        {
            if (tr.isRunning)
            {
                tr.stop;
            }
        }
    }

}
