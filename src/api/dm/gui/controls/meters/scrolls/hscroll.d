module api.dm.gui.controls.meters.scrolls.hscroll;

import api.dm.gui.controls.meters.scrolls.base_regular_mono_scroll: BaseRegularMonoScroll;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class HScroll : BaseRegularMonoScroll
{
    this(float minValue = 0, float maxValue = 1.0)
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
        if (width == 0)
        {
            initWidth = theme.controlDefaultWidth;
        }
    }

    override Sprite2d newThumbShape(float w, float h, float angle, GraphicStyle style)
    {
        return theme.shape(w, h, angle, style);
    }

    override bool delegate(float, float) newOnThumbDragXY()
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

    protected bool trySetThumbX(float x, bool isAllowClamp = true)
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

    override protected float wheelValue(float wheelDt)
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

    alias value = BaseRegularMonoScroll.value;

    override bool value(float v, bool isTriggerListeners = true)
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
