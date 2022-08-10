module deltotum.particles.particle;

import deltotum.graphics.shapes.circle: Circle;
import deltotum.graphics.styles.graphic_style: GraphicStyle;
import deltotum.math.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
//TODO Particle : DisplayObject
class Particle : Circle
{
    @property bool isAlive;
    @property int lifetime;
    @property int age;

     this(double radius, GraphicStyle style, double borderWidth = 1.0)
    {
        super(radius, style, borderWidth);
    }
}
