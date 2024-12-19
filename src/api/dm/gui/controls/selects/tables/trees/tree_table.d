module api.dm.gui.controls.selects.tables.trees.tree_table;

import api.dm.gui.controls.selects.tables.base_table : BaseTable;
import api.dm.gui.containers.scroll_box : ScrollBox;
import api.dm.gui.controls.control : Control;
import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.rect2 : Rect2d;
import api.dm.gui.controls.texts.text : Text;

import api.dm.gui.controls.selects.tables.trees.tree_item : TreeItem;
import api.dm.gui.controls.selects.tables.trees.tree_row : TreeRow;

import api.math.insets : Insets;
import Math = api.math;

import std.container.dlist : DList;

/**
 * Authors: initkfs
 */
class TreeTable(T) : BaseTable
{
    TreeRow!T[] rows;

    protected
    {
        Container itemContainer;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void loadTheme()
    {
        super.loadTheme;
    }

    override void create()
    {
        super.create;

        tryCreateRowContainer(this, isClipping:
            false);

        import api.dm.gui.containers.vbox : VBox;

        itemContainer = new VBox(0);

        if (auto scrollContainer = cast(ScrollBox) rowContainer)
        {
            scrollContainer.setContent(itemContainer);
        }
        else
        {
            addCreate(itemContainer);
        }
    }

    override Container newRowContainer()
    {
        auto container = new ScrollBox(width, height);
        return container;
    }

    protected void buildTree(
        Sprite2d root,
        TreeItem!T item,
        TreeRow!T parent = null,
        size_t treeLevel = 0)
    {
        const canExpand = item.childrenItems.length > 0;

        auto row = new TreeRow!T(item, canExpand, treeLevel);

        import api.dm.kit.graphics.colors.rgba : RGBA;

        row.boundsColor = RGBA.blue;
        row.isDrawBounds = true;

        if (rowContainer)
        {
            row.width = rowContainer.width;
        }

        row.isExpandable = canExpand;
        if (parent)
        {
            parent.childrenRows ~= row;
            row.parentRow = parent;
        }

        root.addCreate(row);
        rows ~= row;

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

    override bool clear()
    {
        if (rows.length == 0)
        {
            return false;
        }

        if (itemContainer)
        {
            itemContainer.removeAll;
        }

        rows = [];
        return true;
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

        assert(itemContainer);

        foreach (item; items)
        {
            buildTree(itemContainer, item);
        }
    }

    void fill(TreeItem!T item)
    {
        TreeItem!T[1] items = [item];
        fill(items);
    }
}
