module api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d;

import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.contexts.graphics_context : GraphicsContext;
import api.dm.kit.sprites2d.textures.vectors.contexts.vector_graphics_context : VectorGraphicsContext;

/**
 * Authors: initkfs
 */
class VShape : VectorTexture
{
    bool isInnerStroke;
    
    //TODO remove from shape
    GraphicStyle style;

    this(double width, double height, GraphicStyle style)
    {
        super(width, height);
        this.style = style;
    }
}
