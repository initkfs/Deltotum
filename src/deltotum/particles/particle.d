module deltotum.particles.particle;

import deltotum.display.bitmap.sprite_sheet : SpriteSheet;
import deltotum.math.vector2d : Vector2D;

/**
 * Authors: initkfs
 */
class Particle : SpriteSheet
{
    @property bool isAlive;
    @property int lifetime;
    @property int age;

    this(int frameWidth = 0, int frameHeight = 0, int frameDelay = 100)
    {
        super(frameWidth, frameHeight, frameDelay);
    }
}
