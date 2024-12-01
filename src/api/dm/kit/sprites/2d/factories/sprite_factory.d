module api.dm.kit.sprites.sprites2d.factories.sprite_factory;

import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
abstract class SpriteFactory(S : Sprite2d) : Sprite2d
{
    abstract S createSprite();
}
