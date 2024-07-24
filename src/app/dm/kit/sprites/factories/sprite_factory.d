module app.dm.kit.sprites.factories.sprite_factory;

import app.dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
abstract class SpriteFactory(S : Sprite) : Sprite
{
    abstract S createSprite();
}
