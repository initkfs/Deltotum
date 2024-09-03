module api.dm.gui.containers.hsplit_box;

import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.layouts.hlayout : HLayout;
import api.dm.kit.sprites.sprite : Sprite;

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

    Sprite[] contents;
    Sprite[] separators;

    override void create()
    {
        super.create;

        window.showingTasks ~= (dt) {
            separators[0].x = contents[0].bounds.right - separators[0].bounds.halfWidth;
        };
    }

    override void applyLayout()
    {
        super.applyLayout;

        foreach (sep; separators)
        {
            if (sep.height != height)
            {
                sep.height = height;
            }
        }
    }

    void addContent(Sprite[] roots)
    {
        foreach (root; roots)
        {
            addCreate(root);
            contents ~= root;
        }

        createSeparator;
    }

    void createSeparator()
    {
        import api.dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        auto sep = new VRegularPolygon(10, 10,
            GraphicStyle(1, graphics.theme.colorAccent, true, graphics.theme.colorAccent), 0);
        addCreate(sep);
        sep.isLayoutManaged = false;
        sep.isDraggable = true;

        separators ~= sep;

        sep.onPointerEntered ~= (ref e) {
            import api.dm.com.inputs.com_cursor : ComSystemCursorType;

            input.systemCursor.change(ComSystemCursorType.hand);
        };

        sep.onPointerExited ~= (ref e) { input.systemCursor.restore; };

        sep.onDragXY = (x, y) {
            auto bounds = this.bounds;
            const minX = bounds.x;
            const maxX = bounds.right - sep.width;
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

            contents[0].isResizeChildren = true;
            contents[1].isResizeChildren = true;

            if (dx > 0)
            {
                //to left
                if (contents[0].layout)
                {
                    contents[0].layout.isIncreaseRootSize = false;
                    contents[0].layout.isResizeChildren = false;
                }
            }
            else
            {
                //to right
                if (contents[1].layout)
                {
                    contents[1].layout.isIncreaseRootSize = false;
                    contents[1].layout.isResizeChildren = false;
                }
            }

            contents[0].width = contents[0].width - dx;
            contents[1].width = contents[1].width + dx;

            return false;
        };
    }

}
