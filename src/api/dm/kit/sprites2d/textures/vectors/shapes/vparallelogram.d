module api.dm.kit.sprites2d.textures.vectors.shapes.vparallelogram;

import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.parallelogram2 : Parallelogram2f;
import api.math.geom2.vec2 : Vec2f;

/**
 * Authors: initkfs
 */
class VParallelogram : VShape
{
    float angleDeg;
    bool isInverted;

    protected
    {
        Parallelogram2f shape;
    }

    this(float width, float height, float angleDeg, bool isInverted, GraphicStyle style)
    {
        super(width, height, style);
        this.angleDeg = angleDeg;
        this.isInverted = isInverted;
    }

    override void createContent()
    {
        import Math = api.dm.math;

        auto ctx = canvas;

        auto strokeWidth = style.lineWidth;

        Vec2f first;
        Vec2f prev;

        shape.draw(width, height, angleDeg, isInverted, strokeWidth, (i, p) {

            if (i == 0)
            {
                ctx.moveTo(p);
                first = p;
                prev = p;
                return true;
            }

            ctx.lineTo(p);

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
        ctx.closePath;
        ctx.stroke;
    }
}
