module api.dm.kit.sprites.tweens.joins.parallel_tween;

import api.dm.kit.sprites.tweens.joins.tween_manager: TweenManager;

/**
 * Authors: initkfs
 */
class ParallelTween : TweenManager
{
    bool isStopOnAnyStopped;

    override void onFrame()
    {
        foreach (tr; tweens)
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
        foreach (tr; tweens)
        {
            tr.run;
        }
    }

    override void pause()
    {
        super.pause;
        foreach (tr; tweens)
        {
            tr.pause;
        }
    }

    void resume()
    {
        foreach (tr; tweens)
        {
            tr.run;
        }
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
