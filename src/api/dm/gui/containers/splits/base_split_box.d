module api.dm.gui.containers.splits.base_split_box;

import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites2d.layouts.hlayout : HLayout;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

struct DividerData
{
    Sprite2d prev;
    Sprite2d next;
    Sprite2d sep;
}

/**
 * Authors: initkfs
 */
class BaseSplitBox : Container
{
    Sprite2d[] contents;
    DividerData[] dividers;

    Sprite2d delegate(Sprite2d) onNewDivider;
    void delegate(Sprite2d) onCreatedDivider;

    double dividerSize = 0;

    protected
    {

    }

    void delegate(DividerData) onMoveDivider;

    abstract
    {
        bool delegate(double, double) newOnSepDragXY(Sprite2d sep);
        double dividerWidth();
        double dividerHeight();
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadBaseSplitBoxTheme;
    }

    void loadBaseSplitBoxTheme()
    {
        if (dividerSize == 0)
        {
            dividerSize = theme.dividerSize;
            assert(dividerSize > 0);
        }
    }

    override void create()
    {
        super.create;
    }

    void addContent(Sprite2d[] roots)
    {
        foreach (root; roots)
        {
            addCreate(root);

            if (contents.length > 0)
            {
                createDivider(contents[$ - 1], root);
            }

            contents ~= root;
        }
    }

    Sprite2d newDivider()
    {
        import api.dm.kit.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        auto sepStyle = createFillStyle;

        auto newSepWidth = dividerWidth;
        auto newSepHeight = dividerHeight;
        if (newSepWidth == 0)
        {
            newSepWidth = 1;
        }

        if (newSepHeight == 0)
        {
            newSepHeight = 1;
        }

        return newDividerShape(newSepWidth, newSepHeight, angle, sepStyle);
    }

    Sprite2d newDividerShape(double w, double h, double angle, GraphicStyle style)
    {
        auto shape = theme.rectShape(w, h, angle, style);
        return shape; 
    }

    void createDivider(Sprite2d prev, Sprite2d next)
    {
        assert(prev);
        assert(next);

        auto newSep = newDivider;
        auto sep = !onNewDivider ? newSep : onNewDivider(newSep);

        sep.isLayoutManaged = false;
        sep.isDraggable = true;
        sep.isResizedByParent = false;

        addCreate(sep);
        if (onCreatedDivider)
        {
            onCreatedDivider(sep);
        }

        //TODO contains?
        dividers ~= DividerData(prev, next, sep);

        sep.onPointerEnter ~= (ref e) {
            import api.dm.com.inputs.com_cursor : ComSystemCursorType;

            input.systemCursor.change(ComSystemCursorType.hand);
        };

        sep.onPointerExit ~= (ref e) { input.systemCursor.restore; };

        sep.onDragXY = newOnSepDragXY(sep);
    }

    protected DividerData* findDividerUnsafe(Sprite2d sep)
    {
        foreach (ref sd; dividers)
        {
            if (sd.sep is sep)
            {
                return &sd;
            }
        }
        return null;
    }

}
