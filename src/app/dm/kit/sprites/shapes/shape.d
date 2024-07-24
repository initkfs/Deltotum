module app.dm.kit.sprites.shapes.shape;

import app.dm.kit.sprites.sprite : Sprite;

import app.dm.kit.graphics.styles.graphic_style : GraphicStyle;

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
