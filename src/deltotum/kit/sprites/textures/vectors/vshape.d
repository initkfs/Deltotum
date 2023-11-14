module deltotum.kit.sprites.textures.vectors.vshape;

import deltotum.kit.sprites.textures.vectors.vector_texture : VectorTexture;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

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
