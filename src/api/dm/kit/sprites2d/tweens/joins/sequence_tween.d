module api.dm.kit.sprites2d.tweens.joins.sequence_tween;

import api.dm.kit.sprites2d.tweens.joins.tween_manager : TweenManager;
import api.dm.kit.sprites2d.tweens.tween2d : Tween2d;

/**
 * Authors: initkfs
 */
class SequenceTween : TweenManager
{
    Tween2d first;

    protected
    {
        Tween2d _last;
    }

    this()
    {
        isInfinite = true;
    }

    override void onFrame()
    {
        bool isStopping = true;
        foreach (tr; tweens)
        {
            if (!tr.isStopping)
            {
                isStopping = false;
                break;
            }
        }

        if (isStopping)
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

    override bool addTween(Tween2d tr)
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
            if (tr.isPausing)
            {
                tr.run;
            }
        }
    }

    Tween2d last()
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
