module deltotum.ui.controls.scrollbars.vscrollbar;

import deltotum.ui.controls.control : Control;
import deltotum.toolkit.display.textures.texture : Texture;

import deltotum.toolkit.graphics.shapes.shape : Shape;
import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.toolkit.display.layouts.managed_layout : ManagedLayout;
import deltotum.toolkit.graphics.shapes.rectangle : Rectangle;
import deltotum.toolkit.display.alignment : Alignment;

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

    Texture delegate() thumbFactory;
    Texture delegate() trackFactory;

    protected
    {
        Texture thumb;
        Texture track;
    }

    this(double minValue = 0, double maxValue = 1.0, double width = 20, double height = 120)
    {
        this.width = width;
        this.height = height;
        this.minValue = minValue;
        this.maxValue = maxValue;

        this.layout = new ManagedLayout;
    }

    override void initialize()
    {
        super.initialize;

        trackFactory = () {
            import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;
            import deltotum.toolkit.graphics.shapes.rectangle : Rectangle;

            auto trackStyle = GraphicStyle(0.0, graphics.theme.colorAccent);
            auto track = new Rectangle(width / 2, height / 2, trackStyle);
            return track;
        };

        thumbFactory = () {

            import deltotum.toolkit.graphics.shapes.regular_polygon : RegularPolygon;
            import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;

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

        track = trackFactory();
        addCreated(track);

        thumb = thumbFactory();
        addCreated(thumb);
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
