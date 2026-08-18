module api.dm.kit.sprites2d.shapes.rshape2d;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import api.dm.kit.graphics.styles.gstyle : GStyle;

/**
 * Authors: initkfs
 */
abstract class RShape2d : Sprite2d
{
    //TODO remove from shape
    GStyle style;

    this(){
        
    }

    this(float width, float height, GStyle style)
    {
        this.width = width;
        this.height = height;
        this.style = style;
    }
}
