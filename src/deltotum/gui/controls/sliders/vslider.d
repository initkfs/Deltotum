module deltotum.gui.controls.sliders.vslider;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.gui.controls.sliders.base_slider : BaseSlider;
import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.textures.texture : Texture;

import deltotum.kit.sprites.shapes.shape : Shape;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.sprites.layouts.center_layout : CenterLayout;
import deltotum.kit.sprites.shapes.rectangle : Rectangle;
import deltotum.math.geom.alignment : Alignment;
import std.math.operations : isClose;

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

            import deltotum.kit.sprites.shapes.regular_polygon : RegularPolygon;
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

            auto currStyle = ownOrParentStyle;
            
            auto style = currStyle ? *currStyle : GraphicStyle(1, graphics.theme.colorAccent, true, graphics
                    .theme.colorAccent);
            style.isFill = true;

            auto node = new RegularPolygon(width, 30, style, graphics
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

                enum errorDelta = 5;
                if (dy < errorDelta)
                {
                    dy = 0;
                }

                const maxYDt = maxY - thumb.y;
                if (maxYDt < errorDelta)
                {
                    dy += maxYDt;
                }

                if (dy < 0)
                {
                    dy = -dy;
                }
                const numRange = maxValue - minValue;

                double oldValue = value;

                value = minValue + (numRange / range) * dy;

                if (isClose(value, oldValue))
                {
                    return false;
                }

                if (onValue !is null)
                {
                    onValue(value);
                }

                return false;
            };
        }
    }
}
