module api.dm.gui.controls.selects.tables.base_table_column;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
class BaseTableColumn(TItem) : Container
{
    protected
    {
        TItem _item;
        bool _empty;
    }

    Text itemText;
    string itemTextId = "item_text";
    bool isCreateItemText = true;
    Text delegate(Text) onNewItemText;
    void delegate(Text) onConfiguredItemText;
    void delegate(Text) onCreatedItemText;

    dstring delegate(TItem) itemTextProvider;

    Sprite2d leftBorder;
    string leftBorderId = "left_border";

    double dividerSize = 0;

    bool isCreateLeftBorder;
    Sprite2d delegate(Sprite2d) onNewLeftBorder;
    void delegate(Sprite2d) onConfiguredLeftBorder;
    void delegate(Sprite2d) onCreatedLeftBorder;

    this(TItem initItem, double dividerSize)
    {
        this(dividerSize);
        _item = initItem;

        id = "base_table_column";
    }

    this(double dividerSize)
    {
        assert(dividerSize > 0);
        this.dividerSize = dividerSize;

        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout(0);
        layout.isAutoResize = true;
    }

    override void loadTheme()
    {
        super.loadTheme;

        if (padding.left == 0)
        {
            padding.left = theme.controlPadding.left;
        }

        if (padding.right == 0)
        {
            padding.right = theme.controlPadding.right;
        }
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
            it.id = itemTextId;
            itemText = !onNewItemText ? it : onNewItemText(it);

            if (onConfiguredItemText)
            {
                onConfiguredItemText(itemText);
            }

            addCreate(itemText);

            if (onCreatedItemText)
            {
                onCreatedItemText(itemText);
            }

            setText;
        }

        if (!leftBorder && isCreateLeftBorder)
        {
            auto lb = newLeftBorder;
            lb.id = leftBorderId;
            leftBorder = !onNewLeftBorder ? lb : onNewLeftBorder(lb);

            leftBorder.isLayoutManaged = false;
            leftBorder.isResizedWidthByParent = false;
            leftBorder.isResizedHeightByParent = true;

            if (onConfiguredLeftBorder)
            {
                onConfiguredLeftBorder(leftBorder);
            }

            addCreate(leftBorder);
            
            if (onCreatedLeftBorder)
            {
                onCreatedLeftBorder(leftBorder);
            }
        }

        static if (__traits(compiles, TItem.init is null))
        {
            if (_item !is TItem.init)
            {
                text = _item;
            }
        }
        else
        {
            if (_item != TItem.init)
            {
                text = _item;
            }
        }
    }

    override void applyLayout()
    {
        super.applyLayout;
        if (leftBorder && !leftBorder.isLayoutManaged)
        {
            leftBorder.x = x - leftBorder.halfWidth;
        }
    }

    Text newItemText()
    {
        return new Text;
    }

    Sprite2d newLeftBorder()
    {
        return theme.rectShape(dividerSize, height, angle, createFillStyle);
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

    TItem item() => _item;

    void item(TItem item)
    {
        _item = item;
        assert(itemText);
        assert(itemTextProvider);
        assert(setText);
    }

    protected bool setText() => text(item);

    bool text(TItem item)
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
