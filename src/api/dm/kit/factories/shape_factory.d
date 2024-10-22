module api.dm.kit.factories.shape_factory;

import api.dm.kit.components.window_component: WindowComponent;

import api.dm.kit.sprites.shapes.shape : Shape;
import api.dm.kit.sprites.shapes.circle : Circle;
import api.dm.kit.sprites.shapes.rectangle : Rectangle;

import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class ShapeFactory : WindowComponent
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
