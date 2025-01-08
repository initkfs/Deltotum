module api.dm.gui.controls.selects.tables.clipped.base_clipped_flat_table;

import api.dm.gui.controls.selects.tables.clipped.base_clipped_table: BaseClippedTable;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;

import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;

/**
 * Authors: initkfs
 */
abstract class BaseClippedFlatTable(T, TCol:
    BaseTableColumn!T, TRow:
    BaseTableRow!(T, TCol)) : BaseClippedTable!(T, TCol, TRow)
{
    
    TRow[] rows;

    this(size_t columnCount)
    {
        super(columnCount);
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

    TRow newRow()
    {
        auto row = new TRow(dividerSize);

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

    override protected void resizeColumn(size_t index, double newWidth)
    {
        foreach (row; rows)
        {
            row.column(index).width = newWidth;
        }
    }
}
