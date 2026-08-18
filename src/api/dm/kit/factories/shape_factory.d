module api.dm.kit.factories.shape_factory;

import api.dm.kit.components.graphic_component: GraphicComponent;

import api.dm.kit.sprites2d.shapes.rshape2d : RShape2d;
import api.dm.kit.sprites2d.shapes.rcircle : RCircle;
import api.dm.kit.sprites2d.shapes.rrect : RRect;

import api.dm.kit.graphics.styles.gstyle : GStyle;

/**
 * Authors: initkfs
 */
class ShapeFactory : GraphicComponent
{
    RCircle circle(float radius, GStyle style)
    {
        auto shape = new RCircle(radius, style);
        buildInitCreate(shape);
        return shape;
    }

    RRect rectangle(float width, float height, GStyle style)
    {
        auto shape = new RRect(width, height, style);
        buildInitCreate(shape);
        return shape;
    }
}
