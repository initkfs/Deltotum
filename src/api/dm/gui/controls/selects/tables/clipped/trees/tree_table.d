module api.dm.gui.controls.selects.tables.clipped.trees.tree_table;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.selects.tables.clipped.base_clipped_table : BaseClippedTable;
import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.selects.tables.clipped.trees.tree_item : TreeItem;
import api.dm.gui.controls.selects.tables.clipped.trees.tree_row : TreeRow;

/**
 * Authors: initkfs
 */
class TreeTable(T) : BaseClippedTable!(T, BaseTableColumn!T, TreeRow!(T))
{
    TreeItem!T[] items;
    TreeRow!T[] rows;

    this(size_t columnCount)
    {
        super(columnCount);
    }

    override protected void resizeColumn(size_t index, double newWidth)
    {
        // foreach (row; rows)
        // {
        //     row.column(index).width = newWidth;
        // }
    }

    protected void buildTree(
        Sprite2d root,
        TreeItem!T item,
        TreeRow!T parent = null,
        size_t treeLevel = 0)
    {
        const canExpand = item.childrenItems.length > 0;
        auto row = new TreeRow!T(item, canExpand, treeLevel, dividerSize);
        row.width = rowContainer ? rowContainer.width : width; //TODO min height
        if (row.height == 0)
        {
            row.height = 1;
        }

        row.onExpandOldNewValue = (oldv, newv) {
            if (rowContainer)
            {
                rowContainer.setInvalid;
            }
        };
        import api.dm.kit.graphics.colors.rgba : RGBA;

        //row.boundsColor = RGBA.blue;
        //row.isDrawBounds = true;

        row.isExpandable = canExpand;
        if (parent)
        {
            parent.childrenRows ~= row;
            row.parentRow = parent;
        }

        root.addCreate(row);
        rows ~= row;
        foreach (ci; 0 .. columnCount)
        {
            row.createColumn;
            row.setItem;
        }

        // row.onSelectedOldNewValue = (oldv, newv) {
        //     if (row is currentSelected)
        //     {
        //         return;
        //     }
        //     auto oldSelected = currentSelected ? currentSelected : null;
        //     currentSelected = row;
        //     if (onSelectedOldNewRow)
        //     {
        //         onSelectedOldNewRow(oldSelected, currentSelected);
        //     }
        // };

        if (item.childrenItems.length > 0)
        {
            treeLevel++;
            foreach (ch; item.childrenItems)
            {
                buildTree(root, ch, row, treeLevel);
            }
        }
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
        this.items = items;
        assert(itemContainer);

        foreach (item; items)
        {
            buildTree(itemContainer, item);
        }

        alignHeaderColumns;
    }

    void fill(TreeItem!T item)
    {
        fill([item]);
    }
}
