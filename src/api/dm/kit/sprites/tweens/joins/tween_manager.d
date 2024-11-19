module api.dm.kit.sprites.tweens.joins.tween_manager;

import api.dm.kit.sprites.tweens.tween : Tween;

/**
 * Authors: initkfs
 */
class TweenManager : Tween
{
    protected
    {
        Tween[] tweens;
    }

    override void onFrame()
    {

    }

    bool addTween(Tween tr)
    {
        if (!tr)
        {
            throw new Exception("Tween must not be null");
        }

        foreach (oldTr; tweens)
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

        tweens ~= tr;
        return true;
    }

    bool removeTween(Tween tr)
    {
        if (!tr)
        {
            throw new Exception("Tween must not be null");
        }

        import api.core.utils.arrays : drop;

        return drop(tweens, tr);
    }

    bool hasTween(Tween tr)
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
