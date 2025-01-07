module api.dm.gui.controls.selects.tables.base_table_row;

import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;
import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
class BaseTableRow(TItem, TCol:
    BaseTableColumn!TItem) : Container
{
    protected
    {
        TCol[] columns;
    }

    void delegate(bool oldValue, bool newValue) onSelectedOldNewValue;

    bool isSelectable = true;

    dstring delegate(TItem) itemTextProvider;

    Container colContainer;

    bool isCreateColumnContainer = true;
    Container delegate(Container) onNewColumnContainer;
    void delegate(Container) onCreatedColumnContainer;

    double dividerSize = 0;

    Sprite2d bottomBorder;

    bool isCreateBottomBorder = true;
    Container delegate(Sprite2d) onNewBottomBorder;
    void delegate(Sprite2d) onCreatedBottomBorder;

    protected
    {
        bool _selected;
        bool _first;
        bool _last;
        bool _empty;
    }

    this(double dividerSize)
    {
        assert(dividerSize > 0);
        this.dividerSize = dividerSize;

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout(0);
        layout.isAutoResize = true;
        layout.isAlignY = true;

        isCreateInteractions = true;

        id = "base_table_row";
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadBaseTableRowTheme;
    }

    void loadBaseTableRowTheme()
    {

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

    override void create()
    {
        super.create;

        if (isCreateColumnContainer)
        {
            auto newContainer = newColumnContainer;
            colContainer = !onNewColumnContainer ? newContainer : onNewColumnContainer(newContainer);
            addCreate(colContainer);
            if (onCreatedColumnContainer)
            {
                onCreatedColumnContainer(colContainer);
            }
        }

        if (isCreateBottomBorder)
        {
            auto bb = newBottomBorder;
            bottomBorder = !onNewBottomBorder ? bb : onNewBottomBorder(bb);

            bottomBorder.isLayoutManaged = false;

            addCreate(bottomBorder);
            if (onCreatedBottomBorder)
            {
                onCreatedBottomBorder(colContainer);
            }
        }
    }

    override void applyLayout()
    {
        super.applyLayout;
        if (bottomBorder && !bottomBorder.isLayoutManaged)
        {
            bottomBorder.y = boundsRect.bottom - bottomBorder.halfHeight;
        }
    }

    Container newColumnContainer()
    {
        import api.dm.gui.containers.hbox : HBox;

        return new HBox(0);
    }

    Sprite2d newBottomBorder()
    {
        auto borderStyle = createFillStyle;
        auto borderWidth = width == 0 ? 1 : width;
        auto shape = theme.rectShape(borderWidth, dividerSize, angle, borderStyle);
        return shape;
    }

    bool createColumn()
    {
        return createColumn(width);
    }

    bool createColumn(double colWidth)
    {
        assert(isCreated);
        auto col = new TCol(dividerSize);

        if(columns.length > 0){
            col.isCreateLeftBorder = true;
        }

        columns ~= col;

        col.itemTextProvider = itemTextProvider;
        auto h = height - padding.height;

        col.resize(colWidth, h);
        auto root = colContainer ? colContainer : this;
        root.addCreate(col);

        return true;
    }

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
