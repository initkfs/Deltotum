module api.dm.gui.controls.meters.scales.dynamics.hscale_dynamic;

import api.dm.gui.controls.meters.scales.dynamics.base_scale_dynamic : BaseScaleDynamic;
import api.math.geom2.vec2 : Vec2d;
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

    override Vec2d tickStep(double startX, double startY, double tickOffset)
    {
        if (isInvertX)
        {
            startX -= tickOffset;
        }
        else
        {
            startX += tickOffset;
        }
        return Vec2d(startX, startY);
    }

    override Vec2d labelXY(double startX, double startY, Text label, double tickWidth, double tickHeight)
    {
        auto labelX = startX - label.boundsRect.halfWidth;
        auto labelY = !isInvertY ? startY + tickHeight / 2 : startY - label.height - tickHeight / 2;
        return Vec2d(labelX, labelY);
    }

    override Vec2d axisStartPos()
    {
        const startPosY = !isInvertY ? y : boundsRect.bottom;
        return Vec2d(x, startPosY);
    }

    override Vec2d axisEndPos()
    {
        const startPosY = !isInvertY ? y : boundsRect.bottom;
        return Vec2d(boundsRect.right, startPosY);
    }

    override  Vec2d meterStartPos(){
        double startX = !isInvertX ? x : boundsRect.right;
        double startY = !isInvertY ? y : boundsRect.bottom;
        return Vec2d(startX, startY);
    }
}
