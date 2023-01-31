module deltotum.engine.factories.creation_shapes;

import deltotum.engine.display.factories.display_object_factory : DisplayObjectFactory;

import deltotum.engine.graphics.shapes.shape : Shape;
import deltotum.engine.graphics.shapes.circle : Circle;
import deltotum.engine.graphics.shapes.rectangle : Rectangle;

import deltotum.engine.graphics.styles.graphic_style : GraphicStyle;

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
