module dm.kit.sprites.textures.vectors.vshape;

import dm.kit.sprites.textures.vectors.vector_texture : VectorTexture;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;

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

        //TODO exception
        isResizable = false;
    }
}
