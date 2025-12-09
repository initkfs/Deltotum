module api.dm.kit.sprites2d.textures.vectors.shapes.vparallelogram;

import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.parallelogram2 : Parallelogram2d;
import api.math.geom2.vec2: Vec2d;

/**
 * Authors: initkfs
 */
class VParallelogram : VShape
{
    float angleDeg;
    bool isInverted;

    protected
    {
        Parallelogram2d shape;
    }

    this(float width, float height, float angleDeg, bool isInverted, GraphicStyle style)
    {
        super(width, height, style);
        this.angleDeg = angleDeg;
        this.isInverted = isInverted;
    }

    override void createTextureContent()
    {
        import Math = api.dm.math;

        auto ctx = canvas;

        Vec2d prev;
        Vec2d first;

        import api.dm.kit.graphics.canvases.graphic_canvas: GraphicCanvas;

        shape.draw(width, height, angleDeg, isInverted, (i, p) {

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
