module deltotum.gui.controls.scrollbars.vscrollbar;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.textures.texture : Texture;

import deltotum.kit.graphics.shapes.shape : Shape;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.sprites.layouts.center_layout : CenterLayout;
import deltotum.kit.graphics.shapes.rectangle : Rectangle;
import deltotum.kit.sprites.alignment : Alignment;

/**
 * Authors: initkfs
 * TODO remove duplication with slider after testing 
 */
class VScrollbar : Control
{
    double minValue;
    double maxValue;
    double value;

    void delegate(double) onValue;

    Sprite delegate() thumbFactory;
    Sprite delegate() trackFactory;

    protected
    {
        Sprite thumb;
        Sprite track;
    }

    this(double minValue = 0, double maxValue = 1.0, double width = 20, double height = 120)
    {
        this.width = width;
        this.height = height;
        this.minValue = minValue;
        this.maxValue = maxValue;

        this.layout = new CenterLayout;
    }

    override void initialize()
    {
        super.initialize;

        minWidth = 20;
        minHeight = 100;
        maxWidth = width;

        trackFactory = () {
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
            import deltotum.kit.graphics.shapes.regular_polygon : RegularPolygon;

            auto trackStyle = GraphicStyle(0.0, graphics.theme.colorAccent);
            auto track = new RegularPolygon(3, height - 10, trackStyle, 1);
            return track;
        };

        thumbFactory = () {

            import deltotum.kit.graphics.shapes.regular_polygon : RegularPolygon;
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

            auto style = GraphicStyle(1, graphics.theme.colorAccent, true, graphics
                    .theme.colorAccent);

            auto node = new RegularPolygon(width, 15, style, graphics
                    .theme.controlCornersBevel);
            return node;

            // auto thumbStyle = GraphicStyle(0.0, graphics.theme.colorAccent, true, graphics.theme.colorAccent);
            // auto thumb = new Rectangle(width, 10, thumbStyle);
            // //thumb.alignment = Alignment.x;
            // return thumb;
        };
    }

    override void create()
    {
        super.create;

        //track = trackFactory();
        //addCreate(track);

        thumb = thumbFactory();
        thumb.isLayoutManaged = false;
        addCreate(thumb);
        thumb.isDraggable = true;
        thumb.onDrag = (x, y) {
            auto bounds = this.bounds;
            const minY = bounds.y;
            const maxY = bounds.bottom - thumb.height;
            if (y <= minY || y >= maxY)
            {
                return false;
            }
            thumb.y = y;

            const range = bounds.height - thumb.height;
            auto dy = thumb.y - bounds.y;
            if (dy < 0)
            {
                dy = -dy;
            }
            const numRange = maxValue - minValue;
            value = minValue + (numRange / range) * dy;

            if (onValue !is null)
            {
                onValue(value);
            }

            return false;
        };
    }
}
