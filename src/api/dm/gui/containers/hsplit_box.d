module api.dm.gui.containers.hsplit_box;

import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.sprites2d.layouts.hlayout : HLayout;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;

struct SeparatorData
{
    Sprite2d prev;
    Sprite2d next;
    Sprite2d sep;
}

/**
 * Authors: initkfs
 */
class HSplitBox : Container
{
    this()
    {
        layout = new HLayout;
        layout.isAutoResize = true;
    }

    Sprite2d[] contents;
    SeparatorData[] separators;

    override void create()
    {
        super.create;

        window.showingTasks ~= (dt) {
            foreach (sepData; separators)
            {
                Sprite2d left = sepData.prev;
                sepData.sep.x = left.boundsRect.right - sepData.sep.boundsRect.halfWidth;
            }

        };
    }

    override void applyLayout()
    {
        super.applyLayout;

        foreach (sdata; separators)
        {
            if (sdata.sep.height != height)
            {
                sdata.sep.height = height;
            }
        }
    }

    void addContent(Sprite2d[] roots)
    {
        foreach (root; roots)
        {
            addCreate(root);

            if (contents.length > 0)
            {
                createSeparator(contents[$ - 1], root);
            }

            contents ~= root;
        }
    }

    void createSeparator(Sprite2d prev, Sprite2d next)
    {
        assert(prev);
        assert(next);

        import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        auto sep = new VConvexPolygon(7, 7,
            GraphicStyle(1, theme.colorAccent, true, theme.colorAccent), 0);
        addCreate(sep);
        sep.isLayoutManaged = false;
        sep.isDraggable = true;
        sep.isResizedByParent = false;

        separators ~= SeparatorData(prev, next, sep);

        sep.onPointerEnter ~= (ref e) {
            import api.dm.com.inputs.com_cursor : ComSystemCursorType;

            input.systemCursor.change(ComSystemCursorType.hand);
        };

        sep.onPointerExit ~= (ref e) { input.systemCursor.restore; };

        sep.onDragXY = (x, y) {

            auto sepData = findSepData(sep);

            auto prev = sepData.prev;
            auto next = sepData.next;
            
            //auto bounds = this.boundsRect;
            const minX = prev.x;
            const maxX = next.boundsRect.right - sep.width;
            if (x <= minX || x >= maxX)
            {
                return false;
            }

            auto dx = sep.x - x;
            if (dx == 0)
            {
                return false;
            }

            sep.x = x;

            prev.isResizeChildren = true;
            prev.isResizeChildrenAlways = true;
            next.isResizeChildren = true;
            next.isResizeChildrenAlways = true;

            if (dx > 0)
            {
                //to left
                if (prev.layout)
                {
                    prev.layout.isIncreaseRootSize = false;
                    prev.layout.isResizeChildren = false;
                }

                if (next.layout)
                {
                    next.layout.isIncreaseRootSize = true;
                    next.layout.isResizeChildren = true;
                }
            }
            else
            {
                //to right
                if (next.layout)
                {
                    next.layout.isIncreaseRootSize = false;
                    next.layout.isResizeChildren = false;
                }

                if (prev.layout)
                {
                    prev.layout.isIncreaseRootSize = true;
                    prev.layout.isResizeChildren = true;
                }
            }

            prev.width = prev.width - dx;
            next.width = next.width + dx;

            return false;
        };
    }

    protected ref SeparatorData findSepData(Sprite2d sep)
    {
        foreach (ref sd; separators)
        {
            if (sd.sep is sep)
            {
                return sd;
            }
        }
        assert(false);
    }

}
