module dm.kit.sprites.factories.sprite_factory;

import dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
abstract class SpriteFactory(S : Sprite) : Sprite
{
    abstract S createSprite();
}
