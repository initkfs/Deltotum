module deltotum.graphics.shapes.shape;

import deltotum.display.textures.rgba_texture: RgbaTexture;
import deltotum.graphics.styles.graphic_style: GraphicStyle;

/**
 * Authors: initkfs
 */
class Shape : RgbaTexture
{
    @property GraphicStyle style;

    this(double width, double height, GraphicStyle style)
    {
        super(width, height);
        this.style = style;
    }
}
