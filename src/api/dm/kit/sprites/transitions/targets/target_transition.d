module api.dm.kit.sprites.transitions.targets.target_transition;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.transitions.curves.interpolator : Interpolator;
import api.dm.kit.sprites.transitions.min_max_transition : MinMaxTransition;

import api.math.geom2.vec2 : Vec2d;

import std.traits : isIntegral, isFloatingPoint;

/**
 * Authors: initkfs
 */
class TargetTransition(V, Target) : MinMaxTransition!V
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
        foreach (Sprite target; targets)
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
