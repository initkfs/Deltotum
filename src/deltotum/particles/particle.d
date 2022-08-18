module deltotum.particles.particle;

import deltotum.display.display_object : DisplayObject;
import deltotum.graphics.shapes.circle : Circle;
import deltotum.graphics.styles.graphic_style : GraphicStyle;
import deltotum.math.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
class Particle : DisplayObject
{
    @property bool isAlive;
    @property int lifetime;
    @property int age;

    this(){
        super();
    }

    this(DisplayObject[] newChildren)
    {
        super();
        foreach (child; newChildren)
        {
            add(child);
        }
    }

    void alive(bool isObjectAlive)
    {
        isAlive = isObjectAlive;
        isUpdatable = isAlive;
        isVisible = isAlive;
    }

}
