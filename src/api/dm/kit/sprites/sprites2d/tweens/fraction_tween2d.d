module api.dm.kit.sprites.sprites2d.tweens.fraction_tween2d;

import api.dm.kit.sprites.sprites2d.tweens.min_max_tween2d : MinMaxTween2d;
import api.dm.kit.sprites.sprites2d.tweens.curves.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
class FractionTween2d : MinMaxTween2d!double
{
    double value = 0;

    void delegate(double, double)[] onOldNewFrac;

    this(double value = 0, size_t timeMs = 200, Interpolator interpolator = null)
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

    bool removeOnOldNewFrac(void delegate(double, double) dg)
    {
        import api.core.utils.arrays : drop;

        return drop(onOldNewFrac, dg);
    }
}
