module api.dm.kit.sprites.textures.vectors.shapes.vhexagon;

import api.dm.kit.sprites.textures.vectors.shapes.vshape : VShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class VHexagon : VShape
{
    bool isFlat = true;

    protected
    {
        size_t sideCount;
    }

    this(double size, GraphicStyle style, size_t sideCount = 6)
    {
        super(size, size, style);
        this.sideCount = sideCount;
    }

    void drawHexagon(double width, double x, double y)
    {
        if (style.isFill)
        {
            gContext.setColor(style.fillColor);
        }

        const lineWidth = style.lineWidth;

        double r = width / 2 - lineWidth / 2;
        gContext.setLineWidth(lineWidth);

        double segments = Math.PI2 / sideCount;

        foreach (i; 0 .. sideCount)
        {
            double angle = segments * i;
            double newX = x + r * Math.cos(angle);
            double newY = y + r * Math.sin(angle);

            if (i == 0)
            {
                gContext.moveTo(newX, newY);
            }
            else
            {
                gContext.lineTo(newX, newY);
            }
        }

        gContext.closePath;

        if (style.isFill)
        {
            gContext.fillPreserve;
        }

        gContext.setColor(style.lineColor);
        gContext.stroke;
    }

    override void createTextureContent()
    {
        drawHexagon(width, width / 2, height / 2);
    }
}
