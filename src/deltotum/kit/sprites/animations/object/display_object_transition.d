module deltotum.kit.sprites.animations.object.display_object_transition;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.sprites.animations.interp.interpolator : Interpolator;
import deltotum.kit.sprites.animations.transition: Transition;

import deltotum.math.vector2d: Vector2d;

import std.traits: isIntegral, isFloatingPoint;

/**
 * Authors: initkfs
 */
class DisplayObjectTransition(T) if (isIntegral!T || isFloatingPoint!T || is(T : Vector2d)) : Transition!T
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

    override void destroy()
    {
        super.destroy;
        displayObject = null;
    }

}
