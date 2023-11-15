module dm.kit.sprites.shapes.shape;

import dm.kit.sprites.sprite : Sprite;

import dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
abstract class Shape : Sprite
{
    //TODO remove from shape
    GraphicStyle style;

    this(double width, double height, GraphicStyle style)
    {
        this.width = width;
        this.height = height;
        this.style = style;
    }
}
