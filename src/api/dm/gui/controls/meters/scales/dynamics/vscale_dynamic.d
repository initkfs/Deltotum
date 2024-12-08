module api.dm.gui.controls.meters.scales.dynamics.vscale_dynamic;

import api.dm.gui.controls.meters.scales.dynamics.base_scale_dynamic : BaseScaleDynamic;
import api.math.geom2.vec2 : Vec2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.texts.text : Text;
import api.math.geom2.line2 : Line2d;

import Math = api.math;

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
        import std : swap;

        swap(tickMinorWidth, tickMinorHeight);
        swap(tickMajorWidth, tickMajorHeight);

        if (_width == 0)
        {
            _width = tickMaxWidth;
        }
    }

    override void createLabelPool()
    {
        super.createLabelPool;

        if (maxLabelWidth > 0)
        {
            width = width + maxLabelWidth;
        }
    }

    override double tickOffset() => height / (tickCount - 1);

    override Vec2d tickStep(size_t i, Vec2d pos, double tickOffset)
    {
        if (isInvertY)
        {
            pos.y += tickOffset;
        }
        else
        {
            pos.y -= tickOffset;
        }
        return pos;
    }

    override Vec2d tickXY(Vec2d pos, double tickWidth, double tickHeight, bool isMajorTick)
    {
        auto tickX = isMajorTick ? pos.x : pos.x + tickWidth / 2;

        auto tickY = pos.y - tickHeight / 2;
        return Vec2d(tickX, tickY);
    }

    override bool drawLabel(size_t labelIndex, size_t tickIndex, Vec2d pos, bool isMajorTick, double offsetTick)
    {
        if (!isMajorTick || labelIndex >= labels.length)
        {
            return false;
        }

        auto label = labels[labelIndex];

        auto tickWidth = tickMajorWidth;

        auto labelX = !isInvertX ? boundsRect.x + tickWidth
            : boundsRect.right - tickWidth - label.width;
        auto labelY = pos.y - label.boundsRect.halfHeight;

        if (tickIndex == 0)
        {
            if (!isInvertY)
            {
                labelY -= label.boundsRect.halfHeight;
            }
            else
            {
                labelY += label.boundsRect.halfHeight;
            }
        }
        else
        {
            if (tickCount > 1 && (tickCount - 1) == tickIndex)
            {
                if (!isInvertY)
                {
                    labelY += label.boundsRect.halfHeight;
                }
                else
                {
                    labelY -= label.boundsRect.halfHeight;
                }
            }
        }

        label.xy(labelX, labelY);
        showLabelIsNeed(labelIndex, label);
        return true;
    }

    override Line2d axisPos()
    {
        const tickHalfMaxW = tickMaxWidth / 2;
        auto startPosX = isInvertX ? boundsRect.right - tickHalfMaxW : x + tickHalfMaxW;
        const start = Vec2d(startPosX, y);
        const end = Vec2d(startPosX, boundsRect.bottom);
        return Line2d(start, end);
    }

    override Vec2d tickStartPos()
    {
        double startX = !isInvertX ? x : boundsRect.right - tickMaxWidth;
        double startY = !isInvertY ? boundsRect.bottom : y;

        return Vec2d(startX, startY);
    }
}
