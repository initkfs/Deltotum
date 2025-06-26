module api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d;

import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;
import api.dm.kit.sprites2d.textures.vectors.canvases.vector_canvas : VectorCanvas;

/**
 * Authors: initkfs
 */
class VShape : VectorTexture
{
    bool isInnerStroke;

    //TODO remove from shape
    GraphicStyle style;

    double shapeAngleDeg = 0;

    bool isClosePath;
    bool isDrawFromCenter;

    double translateX = 0;
    double translateY = 0;

    this(double width, double height, GraphicStyle style)
    {
        super(width, height);
        this.style = style;
    }

    override void createTextureContent()
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
