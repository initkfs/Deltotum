module api.dm.kit.sprites.textures.vectors.shapes.vparallelogram;

import api.dm.kit.sprites.textures.vectors.shapes.vshape : VShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.sprite : Sprite;
import api.math.geom2.parallelogram2 : Parallelogram2d;
import api.math.geom2.vec2: Vec2d;

/**
 * Authors: initkfs
 */
class VParallelogram : VShape
{
    double angleDeg;

    protected
    {
        Parallelogram2d shape;
    }

    this(double width, double height, double angleDeg, GraphicStyle style)
    {
        super(width, height, style);
        this.angleDeg = angleDeg;
    }

    override void createTextureContent()
    {
        import Math = api.dm.math;

        auto ctx = canvas;

        Vec2d prev;
        Vec2d first;

        import api.dm.kit.graphics.contexts.graphics_context: GraphicsContext;

        shape.draw(width, height, angleDeg, (i, p) {

            if (i == 0)
            {
                ctx.moveTo(p);
                first = p;
            }else {
                ctx.lineTo(p);
            }

            prev = p;

            return true;
        });

        ctx.lineTo(first);

        if (style.isFill)
        {
            ctx.color = style.fillColor;
            ctx.fillPreserve;
        }

        ctx.color = style.lineColor;
        ctx.lineWidth = style.lineWidth;
        ctx.stroke;
    }
}
