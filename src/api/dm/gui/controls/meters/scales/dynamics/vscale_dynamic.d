module api.dm.gui.controls.meters.scales.dynamics.vscale_dynamic;

import api.dm.gui.controls.meters.scales.dynamics.base_scale_dynamic : BaseScaleDynamic;
import api.math.geom2.vec2 : Vec2f;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.texts.text : Text;
import api.math.geom2.line2 : Line2f;

import Math = api.math;

/**
 * Authors: initkfs
 */
class VScaleDynamic : BaseScaleDynamic
{
    this(float width = 0, float height = 0)
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

        if (width == 0)
        {
            setInitWidth;
        }
    }

    protected void setInitWidth(){
        initWidth = tickMaxWidth;
    }

    override void createLabelPool()
    {
        super.createLabelPool;

        if (maxLabelWidth > 0)
        {
            setInitWidth;
            width = width + maxLabelWidth;
        }
    }

    override float tickOffset() => height / (tickCount - 1);

    override Vec2f tickStep(size_t i, Vec2f pos, float tickOffset)
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

    override Vec2f tickXY(Vec2f pos, float tickWidth, float tickHeight, bool isMajorTick)
    {
        auto tickX = isMajorTick ? pos.x : pos.x + tickWidth / 2;

        auto tickY = pos.y - tickHeight / 2;
        return Vec2f(tickX, tickY);
    }

    override bool drawLabel(size_t labelIndex, size_t tickIndex, Vec2f pos, bool isMajorTick, float offsetTick)
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

    override Line2f axisPos()
    {
        const tickHalfMaxW = tickMaxWidth / 2;
        auto startPosX = isInvertX ? boundsRect.right - tickHalfMaxW : x + tickHalfMaxW;
        const start = Vec2f(startPosX, y);
        const end = Vec2f(startPosX, boundsRect.bottom);
        return Line2f(start, end);
    }

    override Vec2f tickStartPos()
    {
        float startX = !isInvertX ? x : boundsRect.right - tickMaxWidth;
        float startY = !isInvertY ? boundsRect.bottom : y;

        return Vec2f(startX, startY);
    }
}
