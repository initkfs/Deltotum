module deltotum.factories.creation_objects;

import deltotum.application.components.uni.uni_component : UniComponent;

import deltotum.display.display_object : DisplayObject;

/**
 * Authors: initkfs
 */
class CreationObjects : UniComponent
{

    DisplayObject buildCreated(DisplayObject obj)
    {
        build(obj);
        obj.create;

        assert(obj.isCreated);

        if (!obj.isCreated)
        {
            //TODO log, exceptions?
        }
        return obj;
    }

}
