module api.dm.gui.controls.selects.tables.base_table_row;

import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;
import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
import api.dm.gui.containers.container : Container;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
class BaseTableRow(TItem, TCol : BaseTableColumn!TItem) : Container
{
    protected
    {
        TCol[] columns;
    }

    void delegate(bool oldValue, bool newValue) onSelectedOldNewValue;

    bool isSelectable = true;

    dstring delegate(TItem) itemTextProvider;

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

    override void loadTheme()
    {
        super.loadTheme;
        loadBaseTableRowTheme;
    }

    void loadBaseTableRowTheme()
    {
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

        if (!itemTextProvider)
        {
            itemTextProvider = (TItem item) {
                import std.conv : to;

                return item.to!dstring;
            };
        }
    }

    bool createColumn()
    {
        assert(isCreated);
        auto col = new TCol;
        columns ~= col;

        col.itemTextProvider = itemTextProvider;

        auto w = (width - padding.width) / columns.length;
        auto h = height - padding.height; 

        foreach (oldCol; columns)
        {
            oldCol.resize(w, h);
        }

        col.resize(w, h);
        addCreate(col);
        col.padding = 0;
        
        return true;
    }

    // import api.dm.kit.sprites2d.sprite2d: Sprite2d;
    // import api.dm.kit.graphics.styles.graphic_style: GraphicStyle;

    // override Sprite2d newBackground(double w, double h, double angle, GraphicStyle style)
    // {
    //     import api.dm.kit.graphics.colors.rgba: RGBA;
    //     return theme.rectShape(w, h, angle, style);
    // }

    void onColumn(scope bool delegate(TCol) onColIsContinue)
    {
        foreach (col; columns)
        {
            if (!onColIsContinue(col))
            {
                break;
            }
        }
    }

    protected void setEmpty(bool newValue)
    {
        if (newValue)
        {
            onColumn((col) { col.setEmpty(true); return true; });
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

    BaseTableColumn!TItem column(size_t index)
    {
        if (index >= columns.length)
        {
            import std.format : format;

            throw new Exception(format("Column index must be less than the columns length %s, but received %s", columns
                    .length, index));
        }
        return columns[index];
    }

    TItem item(size_t colIndex)
    {
        auto col = column(colIndex);
        assert(col.item);
        return col.item;
    }

    void item(size_t colIndex, TItem newItem)
    {
        auto col = column(colIndex);
        //assert(col.item);
        col.item = newItem;
        col.setInvalid;
    }
}
