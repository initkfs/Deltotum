module api.dm.kit.sprites.textures.vectors.shapes.vpoint_shape;

import api.dm.kit.sprites.textures.vectors.shapes.vshape : VShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 */
class VPointShape : VShape
{
    bool isClosePath;
    bool isDrawFromCenter;

    double translateX = 0;
    double translateY = 0;

    void delegate() onDraw;

    Vec2d[] points;

    this(Vec2d[] points, double width, double height, GraphicStyle style = GraphicStyle.simple, bool isDrawFromCenter = false, bool isClosePath = true)
    {
        super(width, height, style);

        this.points = points;

        this.isClosePath = isClosePath;
        this.isDrawFromCenter = isDrawFromCenter;
    }

    override void createTextureContent()
    {
        super.createTextureContent;

        if (points.length < 3)
        {
            return;
        }

        auto ctx = canvas;

        ctx.lineWidth = style.lineWidth;

        auto center = isDrawFromCenter ? Vec2d(width / 2, height / 2) : Vec2d.zero;

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
