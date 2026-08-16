module api.dm.kit.sprites2d.textures.vectors.shapes.vec_regular_poly;

import api.dm.kit.sprites2d.textures.vectors.shapes.vec_shape : VecShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

/**
 * Authors: initkfs
 */
class VecRegularPoly : VecShape
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

    void drawPoly(float width, float x, float y)
    {
        if (style.isFill)
        {
            canvas.color(style.fillColor);
        }

        import api.math.geom2.regular_poly2 : RegularPoly2f;

        const lineWidth = style.lineWidth;
        float radius = width / 2 - lineWidth / 2;
        auto polygon = RegularPoly2f(sideCount, radius);

        canvas.lineWidth(lineWidth);

        Vec2f first;

        polygon.draw((i, p) {
            
            const newX = x + p.x;
            const newY = y + p.y;
            
            if (i == 0)
            {
                first = Vec2f(newX, newY);
                canvas.moveTo(first);
                return true;
            }

            canvas.lineTo(newX, newY);
            return true;
        });

        canvas.lineTo(first);

        canvas.closePath;

        if (style.isFill)
        {
            canvas.color = style.fillColor;
            canvas.fillPreserve;
        }

        canvas.color(style.lineColor);
        canvas.stroke;
    }

    override void createContent()
    {
        drawPoly(width, width / 2, height / 2);
    }
}
