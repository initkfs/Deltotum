module api.dm.gui.controls.scrolls.vscroll;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.scrolls.mono_scroll : MonoScroll;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.textures.texture : Texture;

import api.dm.kit.sprites.shapes.shape : Shape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.layouts.center_layout : CenterLayout;
import api.dm.kit.sprites.shapes.rectangle : Rectangle;
import api.math.alignment : Alignment;
import std.math.operations : isClose;

/**
 * Authors: initkfs
 */
class VScroll : MonoScroll
{
    double thumbHeight = 30;

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
            auto style = createThumbStyle;
            auto node = graphics.theme.background(width, thumbHeight, &style);
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

            thumb.onDragXY = (x, y) {

                const maxY = bounds.bottom - thumb.height;

                if (trySetThumbY(y))
                {
                    return false;
                }

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
                auto newValue = minValue + (numRange / range) * dy;
                if (!super.value(newValue))
                {
                    return false;
                }

                return false;
            };
        }
    }

    protected bool trySetThumbY(double y, bool isAllowClamp = true)
    {
        auto bounds = this.bounds;
        const minY = bounds.y;
        const maxY = bounds.bottom - thumb.height;
        if (y <= minY)
        {
            if(thumb.y != minY && isAllowClamp){
                thumb.y = minY;
                return true;
            }
            return false;
        }

        if (y >= maxY)
        {
            if(thumb.y != maxY && isAllowClamp){
                thumb.y = maxY;
                return true;
            }
            return false;
        }

        thumb.y = y;
        return true;
    }

    override protected double wheelValue(double wheelDt)
    {
        auto newValue = _value;
        if (wheelDt > 0)
        {
            newValue -= valueStep;
        }
        else
        {
            newValue += valueStep;
        }
        return newValue;
    }

    alias value = MonoScroll.value;

    override bool value(double v)
    {
        if (!super.value(v) || !thumb)
        {
            return false;
        }

        const rangeY = bounds.height - thumb.height;
        auto newThumbY = y + rangeY * v / maxValue;
        return trySetThumbY(newThumbY);
    }
}
