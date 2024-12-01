module api.dm.kit.sprites.sprites2d.shapes.shape2d;

import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;

import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
abstract class Shape2d : Sprite2d
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
