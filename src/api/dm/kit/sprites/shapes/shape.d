module api.dm.kit.sprites.shapes.shape;

import api.dm.kit.sprites.sprite : Sprite;

import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
abstract class Shape : Sprite
{
    //TODO remove from shape
    GraphicStyle style;

    this(){
        
    }

    this(double width, double height, GraphicStyle style)
    {
        this.width = width;
        this.height = height;
        this.style = style;
    }
}
