module deltotum.display.animation.object.display_object_transition;

import deltotum.display.display_object : DisplayObject;
import deltotum.display.animation.interp.interpolator : Interpolator;
import deltotum.display.animation.transition: Transition;

import deltotum.math.vector2d: Vector2d;

import std.traits: isIntegral, isFloatingPoint;

/**
 * Authors: initkfs
 */
class DisplayObjectTransition(T) if (isIntegral!T || isFloatingPoint!T || is(T : Vector2d)) : Transition!T
{
    protected
    {
        @property DisplayObject displayObject;
    }

    this(DisplayObject obj, T minValue, T maxValue, int timeMs, Interpolator interpolator = null)
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