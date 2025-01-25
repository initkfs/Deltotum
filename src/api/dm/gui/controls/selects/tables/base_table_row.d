module api.dm.gui.controls.selects.tables.base_table_row;

import api.dm.gui.controls.selects.selectable : Selectable;
import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;
import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
class BaseTableRow(TItem, TCol:
    BaseTableColumn!TItem) : Container, Selectable
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
    void delegate(Container) onConfiguredColumnContainer;
    void delegate(Container) onCreatedColumnContainer;

    double dividerSize = 0;

    Sprite2d bottomBorder;
    string bottomBorderId = "bottom_border";

    bool isCreateBottomBorder = true;
    Container delegate(Sprite2d) onNewBottomBorder;
    void delegate(Sprite2d) onConfiguredBottomBorder;
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

            if (colContainer.isBackground)
            {
                if (colContainer.width == 0)
                {
                    colContainer.width = 1;
                }
                if (colContainer.height == 0)
                {
                    colContainer.height = 1;
                }
            }

            if (onConfiguredColumnContainer)
            {
                onConfiguredColumnContainer(colContainer);
            }

            addCreate(colContainer);

            //TODO side effect
            if (isSelectable && colContainer.hasBackground)
            {
                colContainer.backgroundUnsafe.isVisible = false;
            }

            if (onCreatedColumnContainer)
            {
                onCreatedColumnContainer(colContainer);
            }
        }

        if (isCreateBottomBorder)
        {
            auto bb = newBottomBorder;

            bb.id = bottomBorderId;
            bb.isLayoutManaged = false;
            bb.isResizedWidthByParent = true;
            bb.isResizedHeightByParent = false;

            bottomBorder = !onNewBottomBorder ? bb : onNewBottomBorder(bb);

            if (onConfiguredBottomBorder)
            {
                onConfiguredBottomBorder(bottomBorder);
            }

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

    Sprite2d newSelectEffect()
    {
        return theme.shape(width, height, angle, createFillStyle);
    }

    Container newColumnContainer()
    {
        import api.dm.gui.controls.containers.hbox : HBox;

        auto container = new class HBox
        {
            this()
            {
                super(0);
            }

            import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

            override Sprite2d newBackground()
            {
                auto style = createFillStyle;
                if (!style.isPreset)
                {
                    style.lineWidth = 0;
                    style.fillColor = theme.colorSecondary;
                }
                return super.newBackground(width, height, angle, style);
            }

            override Sprite2d createShape(double w, double h, double angle, GraphicStyle style)
            {
                return theme.rectShape(w, h, angle, style);
            }
        };
        container.isBackground = true;
        container.isConsumeEventIfBackground = false;
        return container;
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

        if (columns.length > 0)
        {
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

    TItem item()
    {
        return item(0);
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

    bool isSelected() => _selected;
    void isSelected(bool v)
    {
        _selected = v;
        if (colContainer && colContainer.hasBackground)
        {
            colContainer.backgroundUnsafe.isVisible = v;
        }
    }
}
