module dm.kit.sprites.transitions.objects.object_transition;

import dm.kit.sprites.sprite : Sprite;
import dm.math.interps.interpolator : Interpolator;
import dm.kit.sprites.transitions.min_max_transition : MinMaxTransition;

import dm.math.vector2 : Vector2;

import std.traits : isIntegral, isFloatingPoint;

/**
 * Authors: initkfs
 */
class ObjectTransition(T) if (isIntegral!T || isFloatingPoint!T || is(T : Vector2))
    : MinMaxTransition!T
{

    protected
    {
        Sprite[] objects;
    }

    this(T minValue, T maxValue, int timeMs, Interpolator interpolator = null)
    {
        super(minValue, maxValue, timeMs, interpolator);
    }

    override void dispose()
    {
        super.dispose;
        objects = null;
    }

    void onObjects(scope void delegate(Sprite) onObj)
    {
        foreach (Sprite obj; objects)
        {
            assert(obj, "Object for animation must not be null");
            onObj(obj);
        }
    }

    void addObject(Sprite obj)
    {
        if (!obj)
        {
            throw new Exception("Object for animation must not be null");
        }
        objects ~= obj;
    }

    void clearObjects()
    {
        objects = null;
    }

}
