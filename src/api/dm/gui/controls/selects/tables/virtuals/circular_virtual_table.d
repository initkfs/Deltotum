module api.dm.gui.controls.selects.tables.virtuals.circular_virtual_table;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.rect2 : Rect2d;
import api.dm.gui.controls.texts.text : Text;

import api.dm.gui.controls.selects.tables.virtuals.base_circular_virtual_table : BaseCircularVirtualTable;

import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;
import api.dm.gui.controls.selects.tables.base_table : BaseTable;

auto newCircularVirtualTable(T)(size_t cols)
{
    return new CircularVirtualTable!(T, BaseTableColumn!T, BaseTableRow!(T, BaseTableColumn!T))(cols);
}

/**
 * Authors: initkfs
 */
class CircularVirtualTable(T, TCol:
    BaseTableColumn!T, TRow:
    BaseTableRow!(T, TCol)) : BaseCircularVirtualTable!(T, TCol, TRow)
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

        createVisibleRows;
    }

}
