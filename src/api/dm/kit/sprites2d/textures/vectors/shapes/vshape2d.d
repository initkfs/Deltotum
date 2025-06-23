module api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d;

import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;
import api.dm.kit.sprites2d.textures.vectors.canvases.vector_canvas : VectorCanvas;

/**
 * Authors: initkfs
 */
class VShape : VectorTexture
{
    bool isInnerStroke;
    
    //TODO remove from shape
    GraphicStyle style;

    double shapeAngleDeg = 0;

    this(double width, double height, GraphicStyle style)
    {
        super(width, height);
        this.style = style;
    }
}
