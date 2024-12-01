module api.dm.kit.factories.shape_factory;

import api.dm.kit.components.graphics_component: GraphicsComponent;

import api.dm.kit.sprites.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.sprites.sprites2d.shapes.circle : Circle;
import api.dm.kit.sprites.sprites2d.shapes.rectangle : Rectangle;

import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class ShapeFactory : GraphicsComponent
{
    Circle circle(double radius, GraphicStyle style)
    {
        auto shape = new Circle(radius, style);
        buildInitCreate(shape);
        return shape;
    }

    Rectangle rectangle(double width, double height, GraphicStyle style)
    {
        auto shape = new Rectangle(width, height, style);
        buildInitCreate(shape);
        return shape;
    }
}
