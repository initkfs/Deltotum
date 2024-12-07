module api.dm.gui.controls.meters.scales.dynamics.hscale_dynamic;

import api.dm.gui.controls.meters.scales.dynamics.base_scale_dynamic : BaseScaleDynamic;
import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.line2 : Line2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
class HScaleDynamic : BaseScaleDynamic
{
    this(double width = 0, double height = 0)
    {
        super(width, height);
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadHScaleDynamicSizeTheme;
    }

    void loadHScaleDynamicSizeTheme()
    {
        if (_height == 0)
        {
            import Math = api.math;

            const maxH = Math.max(tickMinorHeight, tickMajorHeight);
            _height = maxH;
        }
    }

    override void createLabelPool()
    {
        super.createLabelPool;

        double maxH = 0;
        foreach (label; labelPool)
        {
            if (label.boundsRect.height > maxH)
            {
                maxH = label.boundsRect.height;
            }
        }

        if (maxH > 0)
        {
            auto newHeight = height + maxH;
            height = newHeight;
        }
    }

    override double tickOffset()
    {
        return width / (tickCount - 1);
    }

    override Vec2d tickStep(size_t i, Vec2d pos, double tickOffset)
    {
        if (isInvertX)
        {
            pos.x -= tickOffset;
        }
        else
        {
            pos.x += tickOffset;
        }
        return pos;
    }

    override bool drawLabel(size_t labelIndex, size_t tickIndex, Vec2d pos, bool isMajorTick, double offsetTick)
    {
        if (!isMajorTick || labelIndex >= labels.length)
        {
            return false;
        }

        auto label = labels[labelIndex];

        auto tickHeight = tickMajorHeight;

        auto labelX = pos.x - label.boundsRect.halfWidth;
        auto labelY = !isInvertY ? pos.y + tickHeight / 2 : pos.y - label.height - tickHeight / 2;
        label.xy(labelX, labelY);
        showLabelIsNeed(labelIndex, label);
        return true;
    }

    override Vec2d tickXY(Vec2d pos, double tickWidth, double tickHeight, bool isMajorTick)
    {
        auto tickX = pos.x;
        auto tickY = pos.y - tickHeight / 2;
        return Vec2d(tickX, tickY);
    }

    override Line2d axisPos()
    {
        const startPosY = !isInvertY ? y : boundsRect.bottom;
        auto start = Vec2d(x, startPosY);
        const end = Vec2d(boundsRect.right, startPosY);
        return Line2d(start, end);
    }

    override Vec2d tickStartPos()
    {
        double startX = !isInvertX ? x : boundsRect.right;
        double startY = !isInvertY ? y : boundsRect.bottom;
        return Vec2d(startX, startY);
    }
}
