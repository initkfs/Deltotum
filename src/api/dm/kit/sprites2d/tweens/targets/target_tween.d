module api.dm.kit.sprites2d.tweens.targets.target_tween;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.tweens.curves.interpolator : Interpolator;
import api.dm.kit.sprites2d.tweens.min_max_tween : MinMaxTween;

import api.math.geom2.vec2 : Vec2f;

import std.traits : isIntegral, isFloatingPoint;

/**
 * Authors: initkfs
 */
class TargetTween(V, Target) : MinMaxTween!V
{

    protected
    {
        Target[] targets;
    }

    this(V minValue, V maxValue, int timeMs, Interpolator interpolator = null)
    {
        super(minValue, maxValue, timeMs, interpolator);
    }

    void onTargetsIsContinue(scope bool delegate(Target) onTargetIsContinue)
    {
        foreach (Sprite2d target; targets)
        {
            if (!onTargetIsContinue(target))
            {
                break;
            }
        }
    }

    bool hasTarget(Target target)
    {
        if (!target)
        {
            throw new Exception("Target for animation must not be null");
        }
        foreach (t; targets)
        {
            if (target is t)
            {
                return true;
            }
        }
        return false;
    }

    bool addTarget(Target target)
    {
        if (!target)
        {
            throw new Exception("Target for animation must not be null");
        }

        if (hasTarget(target))
        {
            return false;
        }

        targets ~= target;
        return true;
    }

    bool removeTarget(Target target)
    {
        if (!target)
        {
            throw new Exception("Target for animation must not be null");
        }
        import api.core.utils.arrays : drop;

        return drop(targets, target);
    }

    void clearTargets()
    {
        targets = null;
    }

    override void dispose()
    {
        super.dispose;
        targets = null;
    }

}
