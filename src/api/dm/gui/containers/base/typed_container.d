module api.dm.gui.containers.base.typed_container;

import api.dm.gui.containers.container: Container;
import api.dm.kit.sprites.sprite : Sprite;

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
