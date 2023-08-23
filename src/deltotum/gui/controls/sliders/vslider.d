module deltotum.gui.controls.sliders.vslider;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.gui.controls.sliders.base_slider : BaseSlider;
import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.textures.texture : Texture;

import deltotum.kit.graphics.shapes.shape : Shape;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.sprites.layouts.center_layout : CenterLayout;
import deltotum.kit.graphics.shapes.rectangle : Rectangle;
import deltotum.kit.sprites.alignment : Alignment;

/**
 * Authors: initkfs
 */
class VSlider : BaseSlider
{
    this(double minValue = 0, double maxValue = 1.0, double width = 20, double height = 120)
    {
        super(minValue, maxValue);
        this.width = width;
        this.height = height;
    }

    override void initialize()
    {
        super.initialize;

        thumbFactory = () {

            import deltotum.kit.graphics.shapes.regular_polygon : RegularPolygon;
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

            auto style = GraphicStyle(1, graphics.theme.colorAccent, true, graphics
                    .theme.colorAccent);

            auto node = new RegularPolygon(width, 15, style, graphics
                    .theme.controlCornersBevel);
            return node;
        };
    }

    override void create()
    {
        super.create;

        if (thumbFactory)
        {
            thumb = thumbFactory();
            
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
}
