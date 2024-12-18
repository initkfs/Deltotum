module api.dm.gui.controls.selects.trees.tree_item;
/**
 * Authors: initkfs
 */
class TreeItem(T)
{
    T item;
    TreeItem!T parentItem;
    TreeItem!T[] childrenItems;

    this(T item, TreeItem parent = null, TreeItem!T[] children = null)
    {
        this.item = item;
        this.parentItem = parent;
        this.childrenItems = children;
    }
}
