module deltotum.kit.sprites.factories.display_object_factory;

import deltotum.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
abstract class DisplayObjectFactory(DO : Sprite) : Sprite
{
    abstract DO createObject();

    protected void buildCreate(Sprite obj)
    {
        build(obj);
        obj.create;
    }
}
