module api.dm.kit.sprites2d.textures.vectors.shapes.vstar;

import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class VStar : VShape
{
    protected
    {
        size_t _spikeCount; 
        double _innerRadius = 0; 
    }

    this(double size, GraphicStyle style, size_t spikeCount = 3, double innerRadius = 5)
    {
        super(size, size, style);
        assert(innerRadius <= size / 2);
        _spikeCount = spikeCount;
        _innerRadius = innerRadius;
    }

    void drawPolygon(double width, double x, double y)
    {
        if (style.isFill)
        {
            canvas.color(style.fillColor);
        }

        import api.math.geom2.star_polygon2 : StarPolygon2d;

        const lineWidth = style.lineWidth;
        auto polygon = StarPolygon2d(_spikeCount, _innerRadius, width / 2);

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
