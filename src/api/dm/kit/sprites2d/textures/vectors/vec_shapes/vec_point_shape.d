module api.dm.kit.sprites2d.textures.vectors.vec_shapes.vec_point_shape;

import api.dm.kit.sprites2d.textures.vectors.vec_shapes.vec_shape : VecShape;
import api.dm.kit.graphics.styles.gstyle : GStyle;
import api.math.geom2.vec2 : Vec2f;

/**
 * Authors: initkfs
 */
class VecPointShape : VecShape
{
    bool isClosePath;
    bool isDrawFromCenter;

    float translateX = 0;
    float translateY = 0;

    void delegate() onDraw;

    Vec2f[] points;

    this(Vec2f[] points, float width, float height, GStyle style = GStyle.simple, bool isDrawFromCenter = false, bool isClosePath = true)
    {
        super(width, height, style);

        this.points = points;

        this.isClosePath = isClosePath;
        this.isDrawFromCenter = isDrawFromCenter;
    }

    override void createContent()
    {
        super.createContent;

        if (points.length < 3)
        {
            return;
        }

        auto ctx = canvas;

        ctx.lineWidth = style.lineWidth;

        auto center = isDrawFromCenter ? Vec2f(width / 2, height / 2) : Vec2f.zero;

        ctx.moveTo(center.add(points[0]));

        foreach (ref p; points[1 .. $])
        {
            ctx.lineTo(center.add(p));
        }

        if (isClosePath)
        {
            ctx.lineTo(center.add(points[0]));
        }

        if (style.isFill)
        {
            ctx.color = style.fillColor;
            ctx.fillPreserve;
        }

        ctx.color = style.lineColor;
        ctx.stroke;
    }
}
