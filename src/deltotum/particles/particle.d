module deltotum.particles.particle;

import deltotum.graphics.shape.circle: Circle;
import deltotum.graphics.shape.shape_style : ShapeStyle;
import deltotum.math.vector2d : Vector2D;

/**
 * Authors: initkfs
 */
//TODO Particle : DisplayObject
class Particle : Circle
{
    @property bool isAlive;
    @property int lifetime;
    @property int age;

     this(double radius, ShapeStyle* style, double borderWidth = 1.0)
    {
        super(radius, style, borderWidth);
    }
}
