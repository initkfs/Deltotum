module deltotum.display.factories.display_object_factory;

import deltotum.display.display_object : DisplayObject;

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
