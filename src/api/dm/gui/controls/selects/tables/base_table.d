module api.dm.gui.controls.selects.tables.base_table;

import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.selects.base_selector : BaseSelector;

import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;
import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;

import api.dm.gui.controls.containers.splits.hsplit_box : HSplitBox;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

class TableHeader : HSplitBox
{
    protected
    {
        size_t columnCount;
    }

    //TODO replace with class field
    static immutable string indexKey = "headerIndex";

    Text[] labels;

    this(size_t colCount)
    {
        assert(colCount > 0);
        this.columnCount = colCount;

        isBorder = true;
    }

    override void create()
    {
        super.create;

        if (columnCount == 0)
        {
            return;
        }

        foreach (ci; 0 .. columnCount)
        {
            auto label = new Text("Col");
            label.setUserData(indexKey, ci);
            label.padding.left = theme.controlPadding.left;
            label.isReduceWidthHeight = false;
            labels ~= label;
        }

        if (labels.length > 0)
        {
            addContent(cast(Sprite2d[]) labels);
        }
    }

    import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

    override Sprite2d newDividerShape(double w, double h, double angle, GraphicStyle style)
    {
        auto newW = w * 5;
        auto shape = theme.convexPolyShape(newW, h, angle, newW / 2, style);
        return shape;
    }

    override Sprite2d newBackground(double w, double h, double angle, GraphicStyle style)
    {
        return theme.rectShape(w, h, angle, style);
    }

    Text columnLabel(size_t colIndex)
    {
        assert(colIndex < labels.length);
        return labels[colIndex];
    }

    void columnLabelWidth(size_t colIndex, double newWidth)
    {
        columnLabel(colIndex).width = newWidth;
    }

    double columnLabelWidth(size_t colIndex)
    {
        return columnLabel(colIndex).width;
    }

}

/**
 * Authors: initkfs
 */
class BaseTable(T, TCol:
    BaseTableColumn!T, TR:
    BaseTableRow!(T, TCol)) : BaseSelector!TR
{
    Container rowContainer;

    bool isCreateContentContainer = true;
    Container delegate(Container) onNewContentContainer;
    void delegate(Container) onConfiguredContentContainer;
    void delegate(Container) onCreatedContentContainer;

    Container contentContainer;

    bool isCreateRowContainer = true;
    Container delegate(Container) onNewRowContainer;
    void delegate(Container) onConfiguredRowContainer;
    void delegate(Container) onCreatedRowContainer;

    bool isCreateHeader = true;
    TableHeader delegate(TableHeader) onNewHeader;
    void delegate(Container) onConfiguredHeader;
    void delegate(TableHeader) onCreatedHeader;

    TableHeader header;

    protected
    {
        size_t columnCount;
    }

    double dividerSize = 0;

    this(size_t columnCount)
    {
        assert(columnCount > 0);
        this.columnCount = columnCount;

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout(0);
        layout.isAutoResize = true;

        isBorder = true;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadBaseTableTheme;
    }

    void loadBaseTableTheme()
    {
        if (width == 0)
        {
            initWidth = theme.controlDefaultWidth;
        }

        if (height == 0)
        {
            initHeight = theme.controlDefaultHeight * 3;
        }

        if (dividerSize == 0)
        {
            dividerSize = theme.dividerSize / 3;
        }
    }

    override void create()
    {
        super.create;

        if (!header && isCreateHeader)
        {
            auto h = newHeader;
            header = !onNewHeader ? h : onNewHeader(h);

            h.width = width;
            h.dividerSize = dividerSize;
            h.isHGrow = true;

            header.onMoveDivider = (sepData) {
                auto prevCol = sepData.prev;
                auto nextCol = sepData.next;
                assert(prevCol);
                assert(nextCol);

                import api.dm.gui.controls.selects.tables.base_table : TableHeader;

                auto prevIndex = prevCol.getUserData!size_t(TableHeader.indexKey);
                auto nextIndex = nextCol.getUserData!size_t(TableHeader.indexKey);

                resizeColumn(prevIndex, prevCol.width);
                resizeColumn(nextIndex, nextCol.width);
            };

            if (onConfiguredHeader)
            {
                onConfiguredHeader(header);
            }

            addCreate(header);

            if (onCreatedHeader)
            {
                onCreatedHeader(header);
            }
        }

        if (!contentContainer && isCreateContentContainer)
        {
            auto c = newContentContainer;
            contentContainer = !onNewContentContainer ? c : onNewContentContainer(c);

            if (onConfiguredContentContainer)
            {
                onConfiguredContentContainer(contentContainer);
            }

            addCreate(contentContainer);

            if (onCreatedContentContainer)
            {
                onCreatedContentContainer(contentContainer);
            }
        }
    }

    protected void resizeColumn(size_t index, double newWidth)
    {

    }

    void alignHeaderColumns()
    {
        if (header)
        {
            foreach (ci; 0 .. columnCount)
            {
                auto colW = columnWidth(ci);
                header.columnLabelWidth(ci, colW);
            }
        }
    }

    protected double columnWidth(size_t index)
    {
        assert(columnCount > 0);
        return width / columnCount;
    }

    override Sprite2d newBackground(double w, double h, double angle, GraphicStyle style)
    {
        return theme.rectShape(w, h, angle, style);
    }

    TableHeader newHeader()
    {
        auto h = new TableHeader(columnCount);
        return h;
    }

    Container newContentContainer()
    {
        import api.dm.gui.controls.containers.hbox : HBox;

        return new HBox(0);
    }

    Container newRowContainer()
    {
        return new class Container
        {
            override Sprite2d newBackground(double w, double h, double angle, GraphicStyle style)
            {
                return theme.rectShape(w, h, angle, style);
            }
        };
    }

    void tryCreateRowContainer()
    {
        Control root = contentContainerOrThis;
        tryCreateRowContainer(root);
    }

    Control contentContainerOrThis()
    {
        if (contentContainer)
        {
            return contentContainer;
        }
        return this;
    }

    void tryCreateRowContainer(Control root, bool isClipping = true)
    {
        if (!rowContainer && isCreateRowContainer)
        {
            auto nc = newRowContainer;
            rowContainer = !onNewRowContainer ? nc : onNewRowContainer(nc);

            //rowContainer.isBorder = true;

            import api.math.geom2.rect2 : Rect2d;

            if (isClipping)
            {
                import api.math.geom2.rect2 : Rect2d;

                auto clip = Rect2d(0, 0, width, height);
                rowContainer.clip = clip;
                rowContainer.isMoveClip = true;
                rowContainer.isResizeClip = true;
            }

            rowContainer.resize(width, height);

            if (onConfiguredRowContainer)
            {
                onConfiguredRowContainer(rowContainer);
            }

            root.addCreate(rowContainer);

            if (onCreatedRowContainer)
            {
                onCreatedRowContainer(rowContainer);
            }
        }
    }

    bool clear()
    {
        if (rowContainer)
        {
            rowContainer.removeAll;
            return true;
        }

        return false;
    }
}
