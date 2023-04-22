module deltotum.kit.display.factories.display_object_factory;

import deltotum.kit.display.display_object : DisplayObject;

/**
 * Authors: initkfs
 */
abstract class DisplayObjectFactory(DO : DisplayObject) : DisplayObject
{
    abstract DO createObject();

    protected void buildCreate(DisplayObject obj)
    {
        build(obj);
        obj.create;
    }
}
