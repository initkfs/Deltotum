module api.dm.gui.controls.selects.tables.circulars.circular_list;

import api.dm.gui.controls.selects.tables.circulars.base_circular_table : BaseCircularTable;
import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;

auto newCircularList(T)()
{
    return new CircularList!(T, BaseTableColumn!T, BaseTableRow!(T, BaseTableColumn!T));
}

/**
 * Authors: initkfs
 */
class CircularList(T, TCol:
    BaseTableColumn!T, TR:
    BaseTableRow!(T, TCol)) : BaseCircularTable!(T, TCol, TR)
{
    T[] items;

    this()
    {
        super(1);
        isCreateHeader = false;
    }

    override
    {
        size_t rowItems() => items.length;
        T rowItem(size_t rowIndex, size_t colIndex) => items[rowIndex];
    }

    void fill(T[] items)
    {
        clear;

        this.items = items;

        createVisibleRows;
    }
}
