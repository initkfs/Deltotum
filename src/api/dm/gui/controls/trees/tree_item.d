module api.dm.gui.controls.trees.tree_item;
/**
 * Authors: initkfs
 */
class TreeItem(T)
{
    T item;
    TreeItem!T[] children;

    this(T item, TreeItem!T[] children = null)
    {
        this.item = item;
        this.children = children;
    }
}
