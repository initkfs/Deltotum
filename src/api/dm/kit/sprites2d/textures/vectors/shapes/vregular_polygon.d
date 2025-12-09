module api.dm.kit.sprites2d.textures.vectors.shapes.vregular_polygon;

import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class VRegularPolygon : VShape
{
    bool isFlat = true;

    protected
    {
        size_t sideCount;
    }

    this(float size, GraphicStyle style, size_t sideCount = 6)
    {
        super(size, size, style);
        this.sideCount = sideCount;
    }

    void drawPolygon(float width, float x, float y)
    {
        if (style.isFill)
        {
            canvas.color(style.fillColor);
        }

        import api.math.geom2.regular_polygon2 : RegularPolygon2f;

        const lineWidth = style.lineWidth;
        float radius = width / 2 - lineWidth / 2;
        auto polygon = RegularPolygon2f(sideCount, radius);

        canvas.lineWidth(lineWidth);

        polygon.draw((i, p) {
            const newX = x + p.x;
            const newY = y + p.y;
            if (i == 0)
            {
                canvas.moveTo(newX, newY);
            }
            else
            {
                canvas.lineTo(newX, newY);
            }
            return true;
        });

        canvas.closePath;

        if (style.isFill)
        {
            canvas.fillPreserve;
        }

        canvas.color(style.lineColor);
        canvas.stroke;
    }

    override void createTextureContent()
    {
        drawPolygon(width, width / 2, height / 2);
    }
}
