module deltotum.graphics.shape.shape;

import deltotum.display.texture.texture : Texture;
import deltotum.graphics.shape.shape_style : ShapeStyle;

/**
 * Authors: initkfs
 */
class Shape : Texture
{
    @property ShapeStyle* style;

    this(double width, double height, ShapeStyle* style)
    {
        super(width, height);
        this.style = style;
    }
}
