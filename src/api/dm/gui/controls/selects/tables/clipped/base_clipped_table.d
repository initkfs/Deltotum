module api.dm.gui.controls.selects.tables.clipped.base_clipped_table;

import api.dm.gui.controls.control : Control;
import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;
import api.dm.gui.controls.selects.tables.base_table : BaseTable;
import api.dm.gui.containers.scroll_box : ScrollBox;

import Math = api.math;

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

    TR[] rows;

    this(size_t columnCount)
    {
        super(columnCount);
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

        if (header)
        {
            header.onMoveDivider = (sepData) {
                auto prevCol = sepData.prev;
                auto nextCol = sepData.next;
                assert(prevCol);
                assert(nextCol);

                import api.dm.gui.controls.selects.tables.base_table : TableHeader;

                auto prevIndex = prevCol.getUserData!size_t(TableHeader.indexKey);
                auto nextIndex = nextCol.getUserData!size_t(TableHeader.indexKey);

                resizeColumn(prevIndex, prevCol.width);
                resizeColumn(nextIndex, nextCol.width);
            };
        }
    }

    abstract
    {
        size_t rowItems();
        T rowItem(size_t rowIndex, size_t colIndex);
    }

    void createRows()
    {
        assert(itemContainer);

        //TODO cache
        itemContainer.removeAll;
        rows = [];

        foreach (ri; 0 .. rowItems)
        {
            auto row = newRow;
            itemContainer.addCreate(row);
            rows ~= row;
            foreach (ci; 0 .. columnCount)
            {
                auto colW = columnWidth(ci);
                row.createColumn(colW);
                auto item = rowItem(ri, ci);
                row.item(ci, item);
            }

        }

        alignHeaderColumns;
    }

    TR newRow()
    {
        auto row = new TR(dividerSize);

        //FIXME 
        if (rowContainer)
        {
            row.width = rowContainer.width;
        }
        else
        {
            row.width = width;
        }

        if (row.height == 0)
        {
            row.height = 1;
        }

        return row;
    }

    protected void resizeColumn(size_t index, double newWidth)
    {
        foreach (row; rows)
        {
            row.column(index).width = newWidth;
        }
    }

    void alignHeaderColumns()
    {
        if (header)
        {
            foreach (ci; 0 .. columnCount)
            {
                auto colW = columnWidth(ci);
                header.columnLabelWidth(ci, colW);
            }
        }
    }

    protected double columnWidth(size_t index)
    {
        assert(columnCount > 0);
        return width / columnCount;
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
