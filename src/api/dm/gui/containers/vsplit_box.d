module api.dm.gui.containers.vsplit_box;

import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.layouts.vlayout : VLayout;
import api.dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class VSplitBox : Container
{
    this()
    {
        layout = new VLayout;
        layout.isAutoResize = true;
        isDrawBounds = true;
    }

    Sprite[] contents;
    Sprite[] separators;

    override void create()
    {
        super.create;

        window.showingTasks ~= (dt) {
            separators[0].y = contents[0].bounds.bottom - separators[0].bounds.halfHeight;
        };
    }

    override void applyLayout()
    {
        super.applyLayout;

        foreach (sep; separators)
        {
            if (sep.width != width)
            {
                sep.width = width;
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
            const minY = bounds.y;
            const maxY = bounds.bottom - sep.height;
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

            // if(dy > 0){
            //     //up
            // }else {
            //     //down
            // }

            contents[0].height = contents[0].height - dy;
            contents[1].height = contents[1].height + dy;

            return false;
        };
    }

}
