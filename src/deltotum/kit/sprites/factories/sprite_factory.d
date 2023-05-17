module deltotum.kit.sprites.factories.sprite_factory;

import deltotum.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
abstract class SpriteFactory(S : Sprite) : Sprite
{
    abstract S createSprite();
}
