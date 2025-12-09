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
        float _innerRadius = 0; 
    }

    this(float size, GraphicStyle style, size_t spikeCount = 3, float innerRadius = 5)
    {
        super(size, size, style);
        assert(innerRadius <= size / 2);
        _spikeCount = spikeCount;
        _innerRadius = innerRadius;
    }

    void drawPolygon(float width, float x, float y)
    {
        if (style.isFill)
        {
            canvas.color(style.fillColor);
        }

        import api.math.geom2.star_polygon2 : StarPolygon2f;

        const lineWidth = style.lineWidth;
        auto polygon = StarPolygon2f(_spikeCount, _innerRadius, width / 2);

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
