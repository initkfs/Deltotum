module api.dm.gui.controls.meters.scales.dynamics.hscale_dynamic;

import api.dm.gui.controls.meters.scales.dynamics.base_scale_dynamic : BaseScaleDynamic;
import api.math.geom2.vec2 : Vec2f;
import api.math.geom2.line2 : Line2f;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.texts.text : Text;

import Math = api.math;

/**
 * Authors: initkfs
 */
class HScaleDynamic : BaseScaleDynamic
{
    this(float width = 0, float height = 0)
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
        if (height == 0)
        {
            setInitHeight;
        }
    }

    protected void setInitHeight(){
        initHeight = tickMaxHeight;
    }

    override void createLabelPool()
    {
        super.createLabelPool;

        if (maxLabelHeight > 0)
        {
            setInitHeight;
            height = height + maxLabelHeight;
        }
    }

    override float tickOffset() => width / (tickCount - 1);

    override Vec2f tickStep(size_t i, Vec2f pos, float tickOffset)
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

    override bool drawLabel(size_t labelIndex, size_t tickIndex, Vec2f pos, bool isMajorTick, float offsetTick)
    {
        if (!isMajorTick || labelIndex >= labels.length)
        {
            return false;
        }

        auto label = labels[labelIndex];

        auto labelX = pos.x - label.boundsRect.halfWidth;
        auto labelY = !isInvertY ? pos.y + tickMaxHeight : pos.y - label.height;
        
        if (tickIndex == 0)
        {
            if (!isInvertX)
            {
                labelX += label.boundsRect.halfWidth;
            }
            else
            {
                labelX -= label.boundsRect.halfWidth;
            }
        }
        else
        {
            if (tickCount > 1 && (tickCount - 1) == tickIndex)
            {
                if (!isInvertX)
                {
                    labelX -= label.boundsRect.halfWidth;
                }
                else
                {
                    labelX += label.boundsRect.halfWidth;
                }
            }
        }
        
        label.xy(labelX, labelY);
        showLabelIsNeed(labelIndex, label);
        return true;
    }

    override Vec2f tickXY(Vec2f pos, float tickWidth, float tickHeight, bool isMajorTick)
    {
        auto tickX = pos.x - tickWidth / 2;
        auto tickY = isMajorTick ? pos.y : pos.y + tickHeight / 2;
        return Vec2f(tickX, tickY);
    }

    override Line2f axisPos()
    {
        const halfTickMaxH = tickMaxHeight / 2;
        const startPosY = !isInvertY ? y + halfTickMaxH : boundsRect.bottom - halfTickMaxH;
        auto start = Vec2f(x, startPosY);
        const end = Vec2f(boundsRect.right, startPosY);
        return Line2f(start, end);
    }

    override Vec2f tickStartPos()
    {
        float startX = !isInvertX ? x : boundsRect.right;
        float startY = !isInvertY ? y : boundsRect.bottom - tickMajorHeight;

        return Vec2f(startX, startY);
    }
}
