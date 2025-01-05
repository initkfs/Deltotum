module api.dm.gui.controls.selects.tables.base_table_column;

import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;
import api.dm.gui.containers.container : Container;
import api.dm.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
class BaseTableColumn(TI) : Container
{
    protected
    {
        TI _item;
        bool _empty;
    }

    Text itemText;
    bool isCreateItemText = true;
    Text delegate(Text) onNewItemText;
    void delegate(Text) onCreatedItemText;

    dstring delegate(TI) itemTextProvider;

    this()
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;
    }

    override void loadTheme(){
        super.loadTheme;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;
        if (!itemText && isCreateItemText)
        {
            assert(itemTextProvider);
            auto it = newItemText;
            itemText = !onNewItemText ? it : onNewItemText(it);

            addCreate(itemText);
            if (onCreatedItemText)
            {
                onCreatedItemText(itemText);
            }

            setText;
        }
    }

    Text newItemText()
    {
        return new Text;
    }

    void setEmpty(bool newValue)
    {
        if (newValue && itemText)
        {
            itemText.text = "";
        }
    }

    bool isEmpty() => _empty;

    void isEmpty(bool newValue)
    {
        if (_empty == newValue)
        {
            return;
        }
        _empty = newValue;
        setEmpty(_empty);
    }

    TI item() => _item;

    void item(TI item)
    {
        _item = item;
        assert(itemText);
        assert(itemTextProvider);
        assert(setText);
    }

    protected bool setText() => text(item);

    bool text(TI item)
    {
        if (!itemText || !itemTextProvider)
        {
            return false;
        }
        auto text = itemTextProvider(item);
        itemText.text = text;
        return true;
    }
}
