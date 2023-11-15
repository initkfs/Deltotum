module dm.kit.sprites.animations.object.display_object_transition;

import dm.kit.sprites.sprite : Sprite;
import dm.kit.sprites.animations.interp.interpolator : Interpolator;
import dm.kit.sprites.animations.transition: Transition;

import dm.math.vector2: Vector2;

import std.traits: isIntegral, isFloatingPoint;

/**
 * Authors: initkfs
 */
class DisplayObjectTransition(T) if (isIntegral!T || isFloatingPoint!T || is(T : Vector2)) : Transition!T
{
    protected
    {
        Sprite displayObject;
    }

    this(Sprite obj, T minValue, T maxValue, int timeMs, Interpolator interpolator = null)
    {
        super(minValue, maxValue, timeMs, interpolator);
        this.displayObject = obj;
    }

    override void dispose()
    {
        super.dispose;
        displayObject = null;
    }

}
