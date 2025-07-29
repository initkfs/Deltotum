module api.dm.gui.controls.containers.base.typed_container;

import api.dm.gui.controls.containers.container : Container;

/**
 * Authors: initkfs
 */
class TypedContainer(T) : Container
{
    T[] items;

    bool delegate(T) canItemAddToItems;
    void delegate(T) onItemAdd;

    void addCreateItem(T item, long index = -1)
    {
        super.addCreate(item, index);

        if (canItemAddToItems && !canItemAddToItems(item))
        {
            return;
        }
        items ~= item;
        if (onItemAdd)
        {
            onItemAdd(item);
        }
    }

    override bool removeAll(bool isDestroy = true)
    {
        if (super.removeAll(isDestroy))
        {
            items = null;
            return true;
        }

        return false;
    }

    override void dispose()
    {
        super.dispose;
        items = null;
    }

}
