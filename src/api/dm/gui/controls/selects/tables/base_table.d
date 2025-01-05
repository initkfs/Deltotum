module api.dm.gui.controls.selects.tables.base_table;

import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;
import api.dm.gui.containers.container : Container;
import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class BaseTable : Control
{
    Container rowContainer;

    bool isCreateRowContainer = true;
    Container delegate(Container) onNewRowContainer;
    void delegate(Container) onCreatedRowContainer;

    this()
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout(0);
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

    void tryCreateRowContainer()
    {
        tryCreateRowContainer(this);
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

    Container newRowContainer()
    {
        return new Container;
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
