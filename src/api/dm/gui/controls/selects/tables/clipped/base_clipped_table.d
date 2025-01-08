module api.dm.gui.controls.selects.tables.clipped.base_clipped_table;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;
import api.dm.gui.controls.selects.tables.base_table : BaseTable;
import api.dm.gui.controls.containers.scroll_box : ScrollBox;

/**
 * Authors: initkfs
 */
abstract class BaseClippedTable(T, TCol:
    BaseTableColumn!T, TR:
    BaseTableRow!(T, TCol)) : BaseTable
{
    protected
    {
        Container itemContainer;
    }

    this(size_t columnCount)
    {
        super(columnCount);
    }

    override void create()
    {
        super.create;

        tryCreateRowContainer(this, isClipping:
            false);

        import api.dm.gui.controls.containers.vbox : VBox;

        itemContainer = new VBox(0);
        //itemContainer.isDrawBounds = true;
        itemContainer.isHGrow = true;
        itemContainer.layout.isDecreaseRootHeight = true;

        auto root = rowContainer ? rowContainer : this;

        if (auto scrollContainer = cast(ScrollBox) root)
        {
            scrollContainer.setContent(itemContainer);
        }
        else
        {
            root.addCreate(itemContainer);
        }
    }

    override Container newRowContainer()
    {
        auto container = new ScrollBox(width, height);
        container.isBorder = false;
        return container;
    }

    override bool clear()
    {        
        if (itemContainer)
        {
            itemContainer.removeAll;
            return true;
        }

        return false;
    }
}
