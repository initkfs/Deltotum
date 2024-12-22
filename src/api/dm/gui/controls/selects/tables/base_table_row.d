module api.dm.gui.controls.selects.tables.base_table_row;

import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;
import api.dm.gui.containers.container : Container;
import api.dm.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
class BaseTableRow(TI) : Container
{
    protected
    {
        TI _rowItem;
    }

    bool isSelectable = true;

    Text itemText;
    bool isCreateItemText = true;
    Text delegate(Text) onNewItemText;
    void delegate(Text) onCreatedItemText;

    dstring delegate(TI) itemTextProvider;

    protected
    {
        bool _selected;
        bool _first;
        bool _last;
        bool _empty;
    }

    this()
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;
    }

    override void loadTheme(){
        super.loadTheme;
        loadBaseTableRowTheme;
    }

    void loadBaseTableRowTheme(){
        if(padding.left == 0){
            padding.left = theme.controlPadding.left;
        }

        if(padding.right == 0){
            padding.right = theme.controlPadding.right;
        }
    }

    override void initialize()
    {
        super.initialize;

        if (!itemTextProvider)
        {
            itemTextProvider = (TI item) {
                import std.conv : to;

                return item.to!dstring;
            };
        }
    }

    // import api.dm.kit.sprites2d.sprite2d: Sprite2d;
    // import api.dm.kit.graphics.styles.graphic_style: GraphicStyle;

    // override Sprite2d newBackground(double w, double h, double angle, GraphicStyle style)
    // {
    //     import api.dm.kit.graphics.colors.rgba: RGBA;
    //     return theme.rectShape(w, h, angle, style);
    // }

    void createItemText()
    {
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

    protected void setEmpty(bool newValue)
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

    TI rowItem() => _rowItem;

    void rowItem(TI item)
    {
        _rowItem = item;
        setText;
    }

    protected bool setText() => setText(rowItem);

    protected bool setText(TI item)
    {
        if (!itemText)
        {
            return false;
        }
        auto text = itemTextProvider(item);
        itemText.text = text;
        return true;
    }
}
