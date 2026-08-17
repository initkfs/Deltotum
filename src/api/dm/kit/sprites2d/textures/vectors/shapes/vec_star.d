module api.dm.kit.sprites2d.textures.vectors.shapes.vec_star;

import api.dm.kit.sprites2d.textures.vectors.shapes.vec_shape : VecShape;
import api.dm.kit.graphics.styles.gstyle : GStyle;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class VecStar : VecShape
{
    protected
    {
        size_t _spikeCount; 
        float _innerRadius = 0; 
    }

    this(float size, GStyle style, size_t spikeCount = 3, float innerRadius = 5)
    {
        super(size, size, style);
        assert(innerRadius <= size / 2);
        _spikeCount = spikeCount;
        _innerRadius = innerRadius;
    }

    void drawPoly(float width, float x, float y)
    {
        if (style.isFill)
        {
            canvas.color(style.fillColor);
        }

        import api.math.geom2.star_poly2 : StarPoly2f;

        const lineWidth = style.lineWidth;
        auto polygon = StarPoly2f(_spikeCount, _innerRadius, width / 2);

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

    override void createContent()
    {
        drawPoly(width, width / 2, height / 2);
    }
}
