module api.dm.gui.controls.selects.tables.clipped.clipped_list;

import api.dm.gui.controls.selects.tables.clipped.base_clipped_flat_table : BaseClippedFlatTable;

import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;
import api.dm.gui.controls.selects.tables.base_table : BaseTable;

alias SimpleClippedList(T) = ClippedList!(T, BaseTableColumn!T, BaseTableRow!(T, BaseTableColumn!T));

SimpleClippedList!T newSimpleClippedList(T)()
{
    return new SimpleClippedList!T();
}

SimpleClippedList!T newClippedList(T)()
{
    return new newSimpleClippedList!T();
}

/**
 * Authors: initkfs
 */
class ClippedList(T, TCol:
    BaseTableColumn!T, TR:
    BaseTableRow!(T, TCol)) : BaseClippedFlatTable!(T, TCol, TR)
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

        createRows;
    }
}
