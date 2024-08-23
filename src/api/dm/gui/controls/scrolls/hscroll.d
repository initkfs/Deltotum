module api.dm.gui.controls.scrolls.hscroll;

import api.dm.gui.controls.scrolls.base_scroll : BaseScroll;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.textures.texture : Texture;

import api.dm.kit.sprites.shapes.shape : Shape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.layouts.managed_layout : ManagedLayout;
import api.dm.kit.sprites.shapes.rectangle : Rectangle;
import api.dm.math.alignment : Alignment;
import std.math.operations: isClose;

/**
 * Authors: initkfs
 */
class HScroll : BaseScroll
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

            import api.dm.kit.sprites.shapes.regular_polygon : RegularPolygon;
            import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

            auto style = graphics.theme.defaultStyle;
            if(auto currStylePtr = ownOrParentStyle){
                style = *currStylePtr;
            }else {
                style.lineColor = graphics.theme.colorAccent;
                style.fillColor = graphics.theme.colorAccent;
            }

            //TODO from parent style?
            style.isFill = true;

            auto node = graphics.theme.background(30, height, &style);
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
