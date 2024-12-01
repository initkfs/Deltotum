module api.dm.gui.controls.scrolls.hscroll;

import api.dm.gui.controls.scrolls.mono_scroll : MonoScroll;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;

import api.dm.kit.sprites.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.sprites2d.layouts.managed_layout : ManagedLayout;
import api.dm.kit.sprites.sprites2d.shapes.rectangle : Rectangle;
import api.math.alignment : Alignment;
import std.math.operations : isClose;

/**
 * Authors: initkfs
 */
class HScroll : MonoScroll
{
    double thumbWidth = 30;

    this(double minValue = 0, double maxValue = 1.0, double width = 120, double height = 20)
    {
        super(minValue, maxValue);
        _width = width;
        _height = height;
    }

    override void initialize()
    {
        super.initialize;

        if (!thumbFactory)
        {
            thumbFactory = () {
                auto style = createThumbStyle;
                auto node = theme.background(thumbWidth, height, angle, &style);
                return node;
            };
        }
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

                const maxX = boundsRect.right - thumb.width;

                //Setting after super.value freezes thumb
                if (!trySetThumbX(x))
                {
                    return false;
                }

                const range = boundsRect.width - thumb.width;
                auto dx = thumb.x - boundsRect.x;

                enum errorDelta = 5;
                if (dx < errorDelta)
                {
                    dx = 0;
                }

                const maxXDt = maxX - thumb.x;
                if (maxXDt < errorDelta)
                {
                    dx += maxXDt;
                }

                if (dx < 0)
                {
                    dx = -dx;
                }

                const numRange = maxValue - minValue;

                auto newValue = minValue + (numRange / range) * dx;
                if (!super.value(newValue))
                {
                    return false;
                }

                return false;
            };
        }
    }

    protected bool trySetThumbX(double x, bool isAllowClamp = true)
    {
        auto bounds = this.boundsRect;
        const minX = boundsRect.x;
        const maxX = boundsRect.right - thumb.width;
        if (x <= minX)
        {
            if(thumb.x != minX && isAllowClamp){
                thumb.x = minX;
                return true;
            }
            return false;
        }

        if (x >= maxX)
        {
            if(thumb.x != maxX && isAllowClamp){
                thumb.x = maxX;
                return true;
            }
            return false;
        }
        thumb.x = x;
        return true;
    }

    override protected double wheelValue(double wheelDt){
        auto newValue = _value;
        if (wheelDt > 0)
        {
            newValue += valueStep;
        }
        else
        {
            newValue -= valueStep;
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

        const rangeX = boundsRect.width - thumb.width;
        auto newThumbX = x + rangeX * v / maxValue;
        return trySetThumbX(newThumbX);
    }
}
