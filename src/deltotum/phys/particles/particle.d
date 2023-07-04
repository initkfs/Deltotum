module deltotum.phys.particles.particle;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.graphics.shapes.circle : Circle;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.math.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
class Particle : Sprite
{
    bool isAlive;
    int lifetime;
    int age;
}
