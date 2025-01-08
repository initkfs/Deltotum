module api.dm.gui.controls.selects.tables.clipped.trees.tree_item;

import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;

/**
 * Authors: initkfs
 */
class TreeItem(T) : BaseTableItem!T
{
    TreeItem!T parentItem;
    TreeItem!T[] childrenItems;

    this(T item, TreeItem parent = null, TreeItem!T[] children = null)
    {
        super(item);
        this.parentItem = parent;
        this.childrenItems = children;
    }
}
