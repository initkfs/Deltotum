module api.dm.gui.controls.containers.base.typed_container;

import api.dm.gui.controls.containers.container: Container;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
class TypedContainer(T) : Container
{
    protected
    {
        T[] items;
    }
    
    override void dispose()
    {
        super.dispose;
        items = null;
    }

}
