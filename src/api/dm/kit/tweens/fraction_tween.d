module api.dm.kit.tweens.fraction_tween;

import api.dm.kit.tweens.min_max_tween : MinMaxTween;
import api.dm.kit.tweens.curves.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
class FractionTween : MinMaxTween!float
{
    float value = 0;

    void delegate(float, float)[] onOldNewFrac;

    this(float value = 0, size_t timeMs = 200, Interpolator interpolator = null)
    {
        super(0, 1, timeMs, interpolator);
        this.value = value;
    }

    override void initialize()
    {
        super.initialize;

        if (value == 0)
        {
            value = maxValue;
        }

        onOldNewValue ~= (oldV, newV) {
            const oldFrac = value - (value * oldV);
            const newFrac = value - (value * newV);
            if (onOldNewFrac.length > 0)
            {
                foreach (dg; onOldNewFrac)
                {
                    dg(oldFrac, newFrac);
                }
            }
        };
    }

    bool removeOnOldNewFrac(void delegate(float, float) dg)
    {
        import api.core.utils.arrays : drop;

        return drop(onOldNewFrac, dg);
    }
}
