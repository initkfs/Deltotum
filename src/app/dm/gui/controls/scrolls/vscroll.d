module app.dm.gui.controls.scrolls.vscroll;

import app.dm.kit.sprites.sprite : Sprite;
import app.dm.gui.controls.scrolls.base_scroll : BaseScroll;
import app.dm.gui.controls.control : Control;
import app.dm.kit.sprites.textures.texture : Texture;

import app.dm.kit.sprites.shapes.shape : Shape;
import app.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import app.dm.kit.sprites.layouts.center_layout : CenterLayout;
import app.dm.kit.sprites.shapes.rectangle : Rectangle;
import app.dm.math.alignment : Alignment;
import std.math.operations : isClose;

/**
 * Authors: initkfs
 */
class VScroll : BaseScroll
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

            import app.dm.kit.sprites.shapes.regular_polygon : RegularPolygon;
            import app.dm.kit.graphics.styles.graphic_style : GraphicStyle;

            //TODO remove copypaste with HScroll
            auto style = graphics.theme.defaultStyle;
            if(auto currStylePtr = ownOrParentStyle){
                style = *currStylePtr;
            }else {
                style.lineColor = graphics.theme.colorAccent;
                style.fillColor = graphics.theme.colorAccent;
            }

            //TODO from parent style?
            style.isFill = true;

            auto node = graphics.theme.background(width, 30, &style);
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
