module deltotum.engine.particles.particle;

import deltotum.engine.display.display_object : DisplayObject;
import deltotum.engine.graphics.shapes.circle : Circle;
import deltotum.engine.graphics.styles.graphic_style : GraphicStyle;
import deltotum.core.maths.vector2d : Vector2d;

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
