module api.dm.gui.controls.meters.scales.dynamics.vscale_dynamic;

import api.dm.gui.controls.meters.scales.dynamics.base_scale_dynamic : BaseScaleDynamic;
import api.math.geom2.vec2 : Vec2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.texts.text : Text;
import api.math.geom2.line2 : Line2d;

/**
 * Authors: initkfs
 */
class VScaleDynamic : BaseScaleDynamic
{
    this(double width = 0, double height = 0)
    {
        super(width, height);
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadVScaleDynamicSizeTheme;
    }

    void loadVScaleDynamicSizeTheme()
    {
        if (_width == 0)
        {
            import Math = api.math;

            const maxW = Math.max(tickMinorHeight, tickMajorHeight);
            _width = maxW;
        }

        import std : swap;

        swap(tickMinorWidth, tickMinorHeight);
        swap(tickMajorWidth, tickMajorHeight);
    }

    override void createLabelPool()
    {
        super.createLabelPool;

        double maxW = 0;
        foreach (label; labelPool)
        {
            if (label.boundsRect.width > maxW)
            {
                maxW = label.boundsRect.width;
            }
        }

        if (maxW > 0)
        {
            auto newWidth = width + maxW;
            width = newWidth;
        }
    }

    override double tickOffset() => height / (tickCount - 1);

    override Vec2d tickStep(size_t i, double startX, double startY, double tickOffset)
    {
        if (isInvertY)
        {
            startY += tickOffset;
        }
        else
        {
            startY -= tickOffset;
        }
        return Vec2d(startX, startY);
    }

    override Vec2d labelPos(size_t i, double startX, double startY, Text label, double tickWidth, double tickHeight)
    {
        auto labelX = !isInvertX ? boundsRect.x + tickWidth
            : boundsRect.right - tickWidth - label.width;
        auto labelY = startY - label.boundsRect.halfHeight;
        return Vec2d(labelX, labelY);
    }

    override Line2d axisPos()
    {
        auto startPosX = isInvertX ? boundsRect.right : x;
        const start = Vec2d(startPosX, y);
        const end = Vec2d(startPosX, boundsRect.bottom);
        return Line2d(start, end);
    }

    override Vec2d tickStartPos()
    {
        double startX = !isInvertX ? x : boundsRect.right;
        double startY = !isInvertY ? boundsRect.bottom : y;
        return Vec2d(startX, startY);
    }
}
