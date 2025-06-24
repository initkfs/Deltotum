module api.dm.gui.controls.meters.scrolls.vscroll;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.meters.scrolls.base_regular_mono_scroll : BaseRegularMonoScroll;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

import api.dm.kit.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;
import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;
import api.math.pos2.alignment : Alignment;
import std.math.operations : isClose;

import Math = api.math;

/**
 * Authors: initkfs
 */
class VScroll : BaseRegularMonoScroll
{
    double maxDragY = 0;

    this(double minValue = 0, double maxValue = 1.0)
    {
        super(minValue, maxValue);

        isVGrow = true;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadVScrollTheme;
    }

    void loadVScrollTheme()
    {
        if (height == 0)
        {
            initHeight = theme.controlDefaultHeight;
        }
    }

    override Sprite2d newThumbShape(double w, double h, double angle, GraphicStyle style)
    {
        return theme.shape(h, w, angle, style);
    }

    override bool delegate(double, double) newOnThumbDragXY()
    {
        return (x, y) {

            assert(thumb);

            if (maxDragY != 0)
            {
                assert(maxDragY > 0);
                auto currDy = thumb.y - y;
                auto absDy = Math.abs(currDy);
                if (absDy > maxDragY)
                {
                    auto diffY = absDy - maxDragY;
                    if (currDy > 0)
                    {
                        diffY = -diffY;
                    }
                    y -= diffY;
                }
            }

            if (!trySetThumbY(y))
            {
                return false;
            }

            const bounds = boundsRect;
            auto dy = thumb.y - bounds.y;

            const maxY = bounds.bottom - thumb.height;
            const range = bounds.height - thumb.height;

            if (maxDragY == 0)
            {
                const errorDelta = maxDragY == 0 ? 5 : 1;
                if (dy < errorDelta)
                {
                    dy = 0;
                }

                const maxYDt = maxY - thumb.y;
                if (maxYDt < errorDelta)
                {
                    dy += maxYDt;
                }
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

    protected bool trySetThumbY(double y, bool isAllowClamp = true)
    {
        auto bounds = this.boundsRect;
        const minY = bounds.y;
        const maxY = bounds.bottom - thumb.height;
        if (y <= minY)
        {
            if (thumb.y != minY && isAllowClamp)
            {
                thumb.y = minY;
                return true;
            }
            return false;
        }

        if (y >= maxY)
        {
            if (thumb.y != maxY && isAllowClamp)
            {
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

    alias value = BaseRegularMonoScroll.value;

    override bool value(double v, bool isTriggerListeners = true)
    {
        if (!super.value(v, isTriggerListeners) || !thumb)
        {
            return false;
        }

        const rangeY = boundsRect.height - thumb.height;
        auto newThumbY = y + rangeY * v / maxValue;
        return trySetThumbY(newThumbY);
    }
}
