module app.dm.kit.sprites.textures.vectors.shapes.vshape;

import app.dm.kit.sprites.textures.vectors.vector_texture : VectorTexture;
import app.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import app.dm.kit.graphics.contexts.graphics_context : GraphicsContext;
import app.dm.kit.sprites.textures.vectors.contexts.vector_graphics_context : VectorGraphicsContext;

/**
 * Authors: initkfs
 */
class VShape : VectorTexture
{
    //TODO remove from shape
    GraphicStyle style;

    this(double width, double height, GraphicStyle style)
    {
        super(width, height);
        this.style = style;
    }
}
