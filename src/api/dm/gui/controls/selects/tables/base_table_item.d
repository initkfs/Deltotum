module api.dm.gui.controls.selects.tables.base_table_item;

/**
 * Authors: initkfs
 */
class BaseTableItem(T)
{
    T item;

    this(T item) pure @safe
    {
        this.item = item;
    }
}
