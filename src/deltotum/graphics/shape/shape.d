module deltotum.graphics.shape.shape;

import deltotum.display.texture.texture : Texture;
import deltotum.graphics.styles.graphic_style: GraphicStyle;

/**
 * Authors: initkfs
 */
class Shape : Texture
{
    @property GraphicStyle style;

    this(double width, double height, GraphicStyle style)
    {
        super(width, height);
        this.style = style;
    }
}
