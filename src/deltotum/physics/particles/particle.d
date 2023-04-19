module deltotum.physics.particles.particle;

import deltotum.toolkit.display.display_object : DisplayObject;
import deltotum.toolkit.graphics.shapes.circle : Circle;
import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.maths.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
class Particle : DisplayObject
{
    bool isAlive;
    int lifetime;
    int age;

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
