module api.dm.gui.controls.selects.tables.base_table_item;

/**
 * Authors: initkfs
 */
class BaseTableItem(T)
{
    T data;

    this(T data) pure @safe
    {
        this.data = data;
    }
}
