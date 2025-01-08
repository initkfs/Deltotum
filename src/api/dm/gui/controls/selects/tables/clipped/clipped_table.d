module api.dm.gui.controls.selects.tables.clipped.clipped_table;

import api.dm.gui.controls.selects.tables.clipped.base_clipped_flat_table: BaseClippedFlatTable;

import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;
import api.dm.gui.controls.selects.tables.base_table : BaseTable;

auto newClippedTable(T)(size_t cols)
{
    return new ClippedTable!(T, BaseTableColumn!T, BaseTableRow!(T, BaseTableColumn!T))(cols);
}

/**
 * Authors: initkfs
 */
class ClippedTable(T, TCol:
    BaseTableColumn!T, TR:
    BaseTableRow!(T, TCol)) : BaseClippedFlatTable!(T, TCol, TR)
{

    T[][] items;

    this(size_t columnCount)
    {
        super(columnCount);
    }

    override
    {
        size_t rowItems() => items.length;
        T rowItem(size_t rowIndex, size_t colIndex) => items[rowIndex][colIndex];
    }

    void fill(T[][] items)
    {
        clear;

        this.items = items;

        createRows;
    }

}
