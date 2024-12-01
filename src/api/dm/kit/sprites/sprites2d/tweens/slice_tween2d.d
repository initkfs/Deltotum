module api.dm.kit.sprites.sprites2d.tweens.slice_tween2d;

import api.dm.kit.sprites.sprites2d.tweens.tween2d : Tween2d;
import api.dm.kit.tweens.curves.interpolator : Interpolator;
import api.dm.kit.tweens.slice_tween : SliceTween;

/**
 * Authors: initkfs
 */
class SliceTween2d(R) : Tween2d
{
    protected
    {
        SliceTween!R sTween;
    }

    this(size_t timeMs = 200, Interpolator interpolator = null)
    {
        super(new SliceTween!R());
        sTween = cast(SliceTween!R) tween;
    }

    ref R[] range() => sTween.range;
    void range(R[] r)
    {
        sTween.range = r;
    }

    ref void delegate(R[]) onValueSlice() => sTween.onValueSlice;
}
