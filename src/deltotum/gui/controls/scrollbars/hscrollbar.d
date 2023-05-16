module deltotum.gui.controls.scrollbars.hscrollbar;

import deltotum.kit.sprites.sprite: Sprite;
import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.textures.texture : Texture;

import deltotum.kit.graphics.shapes.shape : Shape;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.sprites.layouts.managed_layout : ManagedLayout;
import deltotum.kit.graphics.shapes.rectangle : Rectangle;
import deltotum.kit.sprites.alignment : Alignment;

/**
 * Authors: initkfs
 * TODO remove duplication with slider after testing 
 */
class HScrollbar : Control
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

    this(double minValue = 0, double maxValue = 1.0, double width = 120, double height = 20)
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

        thumbFactory = () {

            import deltotum.kit.graphics.shapes.regular_polygon : RegularPolygon;
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

            auto style = GraphicStyle(1, graphics.theme.colorAccent, true, graphics
                    .theme.colorAccent);

            auto node = new RegularPolygon(15, height, style, graphics
                    .theme.controlCornersBevel);
            return node;

            // auto thumbStyle = GraphicStyle(0.0, graphics.theme.colorAccent, true, graphics
            //         .theme.colorAccent);
            // auto thumb = new Rectangle(10, height, style);
            //thumb.alignment = Alignment.x;
            //return thumb;
        };
    }

    override void create()
    {
        super.create;

        if (trackFactory)
        {
            track = trackFactory();
            addCreate(track);
        }

        if (thumbFactory)
        {
            thumb = thumbFactory();
            addCreate(thumb);
            thumb.isDraggable = true;
            thumb.onDrag = (x, y) {
                auto bounds = this.bounds;
                const minX = bounds.x;
                const maxX = bounds.right - thumb.width;
                if (x <= minX || x >= maxX)
                {
                    return false;
                }
                thumb.x = x;

                const range = bounds.width - thumb.width;
                auto dx = thumb.x - bounds.x;
                if (dx < 0)
                {
                    dx = -dx;
                }
                const numRange = maxValue - minValue;
                value = minValue + (numRange / range) * dx;

                if (onValue !is null)
                {
                    onValue(value);
                }

                return false;
            };
        }
    }
}
