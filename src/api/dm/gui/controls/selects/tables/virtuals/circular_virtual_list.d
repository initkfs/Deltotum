module api.dm.gui.controls.selects.tables.virtuals.circular_virtual_list;

import api.dm.gui.controls.selects.tables.virtuals.base_circular_virtual_table : BaseCircularVirtualTable;
import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;

auto newCircularVirtualList(T)()
{
    return new CircularVirtualList!(T, BaseTableColumn!T, BaseTableRow!(T, BaseTableColumn!T));
}

/**
 * Authors: initkfs
 */
class CircularVirtualList(T, TCol:
    BaseTableColumn!T, TR:
    BaseTableRow!(T, TCol)) : BaseCircularVirtualTable!(T, TCol, TR)
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
