module app.dm.gui.controls.trees.tree_list_view;

import app.dm.gui.controls.control : Control;
import app.dm.gui.containers.scroll_box : ScrollBox;
import app.dm.gui.containers.vbox : VBox;
import app.dm.gui.containers.hbox : HBox;
import app.dm.gui.containers.container : Container;
import app.dm.gui.containers.stack_box : StackBox;
import app.dm.gui.controls.scrolls.hscroll : HScroll;
import app.dm.gui.controls.scrolls.vscroll : VScroll;
import app.dm.kit.sprites.sprite : Sprite;
import app.dm.math.insets : Insets;
import app.dm.math.rect2d : Rect2d;
import app.dm.gui.controls.buttons.button : Button;
import app.dm.gui.controls.texts.text : Text;

import app.dm.gui.controls.trees.tree_item : TreeItem;
import app.dm.gui.controls.trees.tree_row : TreeRow;

/**
 * Authors: initkfs
 */
class TreeListView(T) : ScrollBox
{
    TreeRow!T[] rows;
    T initValue;
    TreeRow!T currentSelected;

    protected
    {
        Container rowContainer;
    }

    Container delegate() rowContainerFactory;

    void delegate(T oldItem, T newItem) onSelectedOldNew;

    this(T initValue = null)
    {
        this.initValue = initValue;

        isBorder = true;
    }

    override void initialize()
    {
        super.initialize;
        if (!rowContainerFactory)
        {
            rowContainerFactory = () { return new VBox(5); };
        }
    }

    override void create()
    {
        super.create;

        if (rowContainerFactory)
        {
            rowContainer = rowContainerFactory();
            assert(rowContainer);
        }
        else
        {
            throw new Exception("Cannot create list, row container factory not found");
        }

        //FIXME what kind of bug is this?
        //addCreate(rowContainer);

        setContent(rowContainer);
        rowContainer.enablePadding;
    }

    protected void buildTree(
        Sprite root,
        TreeItem!T item,
        TreeRow!T parent = null,
        size_t treeLevel = 0)
    {
        const canExpand = item.children.length > 0 ? true : false;
        auto row = new TreeRow!T(item, canExpand, treeLevel);
        row.isExpand = true;
        if (parent)
        {
            parent.children ~= row;
        }
        root.addCreate(row);
        rows ~= row;
        row.padding = Insets(0);
        row.onSelected = () {
            if (row is currentSelected)
            {
                return;
            }
            auto oldSelected = currentSelected !is null ? currentSelected.item.item : initValue;
            currentSelected = row;
            if (onSelectedOldNew)
            {
                onSelectedOldNew(oldSelected, currentSelected.item.item);
            }
        };
        if (item.children.length > 0)
        {
            treeLevel++;
            foreach (ch; item.children)
            {
                buildTree(root, ch, row, treeLevel);
            }
        }
    }

    bool clear()
    {
        if (rows.length == 0)
        {
            return false;
        }

        rows = [];
        rowContainer.removeAll;

        return true;
    }

    private void verifyRows()
    {
        if (rows.length > 0)
        {
            auto lastRow = rows[$ - 1];
            lastRow.setLastRowLabel;
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

        foreach (item; items)
        {
            buildTree(contentRoot, item);
        }
        verifyRows;
    }

    void fill(TreeItem!T item)
    {
        TreeItem!T[1] items = [item];
        fill(items);
    }
}
