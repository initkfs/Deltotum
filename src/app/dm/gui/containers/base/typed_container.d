module app.dm.gui.containers.base.typed_container;

import app.dm.gui.containers.container: Container;
import app.dm.kit.sprites.sprite : Sprite;

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
