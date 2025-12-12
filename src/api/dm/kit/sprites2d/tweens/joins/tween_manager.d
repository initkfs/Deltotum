module api.dm.kit.sprites2d.tweens.joins.tween_manager;

import api.dm.kit.sprites2d.tweens.tween2d : Tween2d;

/**
 * Authors: initkfs
 */
class TweenManager : Tween2d
{
    protected
    {
        Tween2d[] tweens;
    }

    override void onFrame()
    {

    }

    bool addTween(Tween2d tr)
    {
        // if (!tr)
        // {
        //     throw new Exception("Tween2d must not be null");
        // }

        // foreach (oldTr; tweens)
        // {
        //     if (oldTr is tr)
        //     {
        //         return false;
        //     }
        // }

        // if (!tr.isBuilt)
        // {
        //     buildInitCreate(tr);
        // }

        // if (!tr.parent)
        // {
        //     add(tr);
        // }

        // tweens ~= tr;
        return true;
    }

    bool removeTween(Tween2d tr)
    {
        if (!tr)
        {
            throw new Exception("Tween2d must not be null");
        }

        import api.core.utils.arrays : drop;

        return drop(tweens, tr);
    }

    bool hasTween(Tween2d tr)
    {
        foreach (t; tweens)
        {
            if (tr is t)
            {
                return true;
            }
        }
        return false;
    }

    void clearTweens()
    {
        tweens = null;
    }

    override void dispose()
    {
        super.dispose;
        clearTweens;
    }
}
