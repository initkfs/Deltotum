module api.dm.gui.controls.selects.tables.base_table;

import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;
import api.dm.gui.containers.container : Container;
import api.dm.gui.controls.control : Control;

import api.dm.gui.containers.splits.hsplit_box : HSplitBox;
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
        this.columnCount = colCount;
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
            label.isBorder = true;
            label.isReduceWidthHeight = false;
            labels ~= label;
        }

        if (labels.length > 0)
        {
            addContent(cast(Sprite2d[]) labels);
        }
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
class BaseTable : Control
{
    Container rowContainer;

    bool isCreateContentContainer = true;
    Container delegate(Container) onNewContentContainer;
    void delegate(Container) onCreatedContentContainer;

    Container contentContainer;

    bool isCreateRowContainer = true;
    Container delegate(Container) onNewRowContainer;
    void delegate(Container) onCreatedRowContainer;

    bool isCreateHeader = true;
    TableHeader delegate(TableHeader) onNewHeader;
    void delegate(TableHeader) onCreatedHeader;

    TableHeader header;

    protected
    {
        size_t columnCount;
    }

    this(size_t columnCount)
    {
        assert(columnCount > 0);
        this.columnCount = columnCount;

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout(0);
        layout.isAutoResize = true;
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
    }

    override void create()
    {
        super.create;

        if (!header && isCreateHeader)
        {
            auto h = newHeader;
            header = !onNewHeader ? h : onNewHeader(h);

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
            addCreate(contentContainer);
            if (onCreatedContentContainer)
            {
                onCreatedContentContainer(contentContainer);
            }
        }
    }

    TableHeader newHeader()
    {
        auto h = new TableHeader(columnCount);
        h.isBorder = true;
        h.width = width;
        h.isHGrow = true;
        return h;
    }

    Container newContentContainer()
    {
        import api.dm.gui.containers.hbox : HBox;

        return new HBox(0);
    }

    Container newRowContainer()
    {
        return new Container;
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

            rowContainer.isDrawBounds = true;

            import api.dm.kit.graphics.colors.rgba : RGBA;
            import api.math.geom2.rect2 : Rect2d;

            rowContainer.boundsColor = RGBA.yellow;

            if (isClipping)
            {
                import api.math.geom2.rect2 : Rect2d;

                auto clip = Rect2d(0, 0, width, height);
                rowContainer.clip = clip;
                rowContainer.isMoveClip = true;
                rowContainer.isResizeClip = true;
            }

            rowContainer.resize(width, height);

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
