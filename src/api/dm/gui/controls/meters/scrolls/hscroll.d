module api.dm.gui.controls.meters.scrolls.hscroll;

import api.dm.gui.controls.meters.scrolls.base_labeled_scroll : BaseLabeledScroll;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class HScroll : BaseLabeledScroll
{
    this(double minValue = 0, double maxValue = 1.0)
    {
        super(minValue, maxValue);

        isHGrow = true;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadHScrollTheme;
    }

    void loadHScrollTheme()
    {
        if (_width == 0)
        {
            _width = theme.controlDefaultWidth;
        }
    }

    override Sprite2d newThumbShape(double w, double h, double angle, GraphicStyle style)
    {
        return theme.shape(w, h, angle, style);
    }

    override bool delegate(double, double) newOnThumbDragXY()
    {
        return (x, y) {

            //Setting after super.value freezes thumb
            if (!trySetThumbX(x))
            {
                return false;
            }

            const bounds = boundsRect;

            const maxX = bounds.right - thumb.width;

            const range = bounds.width - thumb.width;
            auto dx = thumb.x - bounds.x;

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

    protected bool trySetThumbX(double x, bool isAllowClamp = true)
    {
        auto bounds = this.boundsRect;
        const minX = bounds.x;
        const maxX = bounds.right - thumb.width;
        if (x <= minX)
        {
            if (thumb.x != minX && isAllowClamp)
            {
                thumb.x = minX;
                return true;
            }
            return false;
        }

        if (x >= maxX)
        {
            if (thumb.x != maxX && isAllowClamp)
            {
                thumb.x = maxX;
                return true;
            }
            return false;
        }
        thumb.x = x;
        return true;
    }

    override protected double wheelValue(double wheelDt)
    {
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

    alias value = BaseLabeledScroll.value;

    override bool value(double v, bool isTriggerListeners = true)
    {
        if (!super.value(v, isTriggerListeners) || !thumb)
        {
            return false;
        }

        const rangeX = boundsRect.width - thumb.width;
        auto newThumbX = x + rangeX * v / maxValue;
        return trySetThumbX(newThumbX);
    }
}
