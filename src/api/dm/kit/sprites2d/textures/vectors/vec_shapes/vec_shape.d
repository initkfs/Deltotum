module api.dm.kit.sprites2d.textures.vectors.vec_shapes.vec_shape;

import api.dm.kit.sprites2d.textures.vectors.vec_tex : VecTex;
import api.dm.kit.graphics.styles.gstyle : GStyle;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;
import api.dm.kit.graphics.canvases.vector_canvas : VectorCanvas;

/**
 * Authors: initkfs
 */
class VecShape : VecTex
{
    bool isInnerStroke;

    //TODO remove from shape
    GStyle style;

    float shapeAngleDeg = 0;

    bool isClosePath;
    bool isDrawFromCenter;

    float translateX = 0;
    float translateY = 0;

    this(float width, float height, GStyle style = GStyle.simple)
    {
        super(width, height);
        this.style = style;
        this.id = "vshape";
    }

    override void createContent()
    {
        auto ctx = canvas;

        if (isDrawFromCenter)
        {
            ctx.translate(width / 2 + translateX, height / 2 + translateY);
        }
        else
        {
            if (translateX > 0 || translateY > 0)
            {
                ctx.translate(translateX, translateY);
            }
        }
    }
}
