module api.dm.gui.controls.selects.tables.clipped.trees.tree_list;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.control : Control;

import api.dm.gui.controls.selects.tables.clipped.trees.base_tree_table : BaseTreeTable;
import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.dm.gui.controls.selects.tables.clipped.trees.tree_item : TreeItem;
import api.dm.gui.controls.selects.tables.clipped.trees.tree_row : TreeRow;

auto newTreeList(T)()
{
    return new TreeList!(T, BaseTableColumn!T, TreeRow!T)();
}

/**
 * Authors: initkfs
 */
class TreeList(T, TCol:
    BaseTableColumn!T, TRow:
    TreeRow!T) : BaseTreeTable!(T, TCol, TRow)
{
    TreeItem!T[] items;
    TreeRow!T[] rows;

    this()
    {
        super(1);

        isCreateHeader = false;
    }

    void fill(T[] items)
    {
        TreeItem!T[] treeItems;
        foreach (item; items)
        {
            treeItems ~= new TreeItem!T(item);
        }
        fill(treeItems);
    }

    void fill(TreeItem!T[] items)
    {
        clear;

        if(items.length == 0){
            return;
        }

        this.items = items;
        assert(itemContainer);

        auto lastIndex = items.length - 1;

        foreach (item; items)
        {
            buildTree(itemContainer, item, null, 0, 0, lastIndex);
        }

        alignHeaderColumns;

        rowContainer.setInvalid;
    }

    void fill(TreeItem!T item)
    {
        fill([item]);
    }

}
