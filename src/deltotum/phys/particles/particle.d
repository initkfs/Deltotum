module deltotum.phys.particles.particle;

import deltotum.kit.display.display_object : DisplayObject;
import deltotum.kit.graphics.shapes.circle : Circle;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.math.vector2d : Vector2d;

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
