module api.dm.kit.sprites2d.textures.vectors.shapes.vcircle;

import api.dm.kit.sprites2d.textures.vectors.shapes.varc : VArc;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.pos2.insets : Insets;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class VCircle : VArc
{
    bool isSetRadiusFromSize = true;

    this(float radius = 10, GraphicStyle style = GraphicStyle.simpleFill)
    {
        this(radius, style, radius * 2, radius * 2);
    }

    this(float radius, GraphicStyle style, float width, float height)
    {
        super(radius, style, width, height);
        this.toAngleRad = 2 * Math.PI;
    }

    override bool tryWidth(float value)
    {
        if (super.tryWidth(value))
        {
            setRadiusFromSize;
            return true;
        }
        return false;
    }

    override bool tryHeight(float value)
    {
        if (super.tryHeight(value))
        {
            setRadiusFromSize;
            return true;
        }

        return false;
    }

    protected void setRadiusFromSize()
    {
        if (!isSetRadiusFromSize)
        {
            return;
        }
        
        import Math = api.math;

        auto newRadius = Math.min(_width, _height) / 2;
        if (newRadius > 0)
        {
            radius = newRadius;
        }
    }
}
