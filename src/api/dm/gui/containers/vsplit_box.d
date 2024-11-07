module api.dm.gui.containers.vsplit_box;

import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.layouts.vlayout : VLayout;
import api.dm.kit.sprites.sprite : Sprite;

//TODO remove duplication with HSplitBox
struct SeparatorData
{
    Sprite prev;
    Sprite next;
    Sprite sep;
}

/**
 * Authors: initkfs
 */
class VSplitBox : Container
{
    this()
    {
        layout = new VLayout;
        layout.isAutoResize = true;
    }

    Sprite[] contents;
    SeparatorData[] separators;

    override void create()
    {
        super.create;

        window.showingTasks ~= (dt) {
            foreach (sepData; separators)
            {
                Sprite prev = sepData.prev;
                sepData.sep.y = prev.bounds.bottom - sepData.sep.bounds.halfHeight;
            }

        };
    }

    override void applyLayout()
    {
        super.applyLayout;

        foreach (sdata; separators)
        {
            if (sdata.sep.width != width)
            {
                sdata.sep.width = width;
            }
        }
    }

    void addContent(Sprite[] roots)
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

    void createSeparator(Sprite prev, Sprite next)
    {
        assert(prev);
        assert(next);

        import api.dm.kit.sprites.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        auto sep = new VConvexPolygon(7, 7,
            GraphicStyle(1, graphics.theme.colorAccent, true, graphics.theme.colorAccent), 0);
        addCreate(sep);
        sep.isResizedByParent = false;
        sep.isLayoutManaged = false;
        sep.isDraggable = true;

        separators ~= SeparatorData(prev, next, sep);

        sep.onPointerEntered ~= (ref e) {
            import api.dm.com.inputs.com_cursor : ComSystemCursorType;

            input.systemCursor.change(ComSystemCursorType.hand);
        };

        sep.onPointerExited ~= (ref e) { input.systemCursor.restore; };

        sep.onDragXY = (x, y) {

            auto sepData = findSepData(sep);

            auto prev = sepData.prev;
            auto next = sepData.next;

            //auto bounds = this.bounds;
            const minY = prev.y;
            const maxY = next.bounds.bottom - sep.height;
            if (y <= minY || y >= maxY)
            {
                return false;
            }

            auto dy = sep.y - y;
            if (dy == 0)
            {
                return false;
            }

            sep.y = y;

            prev.isResizeChildren = true;
            next.isResizeChildren = true;

            if (dy > 0)
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

            prev.height = prev.height - dy;
            next.height = next.height + dy;

            return false;
        };
    }

    protected ref SeparatorData findSepData(Sprite sep)
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
