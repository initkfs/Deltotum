module deltotum.kit.factories.creation_shapes;

import deltotum.kit.display.factories.display_object_factory : DisplayObjectFactory;

import deltotum.kit.graphics.shapes.shape : Shape;
import deltotum.kit.graphics.shapes.circle : Circle;
import deltotum.kit.graphics.shapes.rectangle : Rectangle;

import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class CreationShapes : DisplayObjectFactory!Shape
{
    override Shape createObject()
    {
        //TODO default shape-placeholder
        return null;
    }

    Circle circle(double radius, GraphicStyle style, double borderWidth = 1.0)
    {
        auto shape = new Circle(radius, style, borderWidth);
        buildCreate(shape);
        return shape;
    }

    Rectangle rectangle(double width, double height, GraphicStyle style)
    {
        auto shape = new Rectangle(width, height, style);
        buildCreate(shape);
        return shape;
    }
}
