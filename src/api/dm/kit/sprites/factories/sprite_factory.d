module api.dm.kit.sprites.factories.sprite_factory;

import api.dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
abstract class SpriteFactory(S : Sprite) : Sprite
{
    abstract S createSprite();
}
