module api.dm.gui.controls.containers.base.typed_container;

import api.dm.gui.controls.containers.container: Container;

/**
 * Authors: initkfs
 */
class TypedContainer(T) : Container
{
    protected
    {
        T[] items;
    }

    alias add = Container.add;

    void add(T component, long index = -1)
    {
        super.add(component, index);
        items ~= component;
    }
    
    override void dispose()
    {
        super.dispose;
        items = null;
    }

}
