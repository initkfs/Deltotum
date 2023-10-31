module deltotum.gui.controls.sliders.hslider;

import deltotum.gui.controls.sliders.base_slider : BaseSlider;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.textures.texture : Texture;

import deltotum.kit.sprites.shapes.shape : Shape;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.sprites.layouts.managed_layout : ManagedLayout;
import deltotum.kit.sprites.shapes.rectangle : Rectangle;
import deltotum.math.geom.alignment : Alignment;
import std.math.operations: isClose;

/**
 * Authors: initkfs
 */
class HSlider : BaseSlider
{

    this(double minValue = 0, double maxValue = 1.0, double width = 120, double height = 20)
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

            auto node = new RegularPolygon(30, height, style, graphics
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
                const minX = bounds.x;
                const maxX = bounds.right - thumb.width;
                if (x <= minX || x >= maxX)
                {
                    return false;
                }
                thumb.x = x;

                const range = bounds.width - thumb.width;
                auto dx = thumb.x - bounds.x;

                enum errorDelta = 5;
                if(dx < errorDelta){
                    dx = 0;
                }

                const maxXDt = maxX - thumb.x;
                if(maxXDt < errorDelta){
                    dx += maxXDt;
                }

                if (dx < 0)
                {
                    dx = -dx;
                }
                const numRange = maxValue - minValue;

                double oldValue = value;

                value = minValue + (numRange / range) * dx;

                valueDelta = value - oldValue;
                if (isClose(valueDelta, 0.0, 0.0, float.epsilon))
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
