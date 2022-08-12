module deltotum.factories.creation_shapes;

import deltotum.factories.creation_objects : CreationObjects;

import deltotum.graphics.shapes.circle : Circle;
import deltotum.graphics.shapes.rectangle : Rectangle;

import deltotum.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class CreationShapes : CreationObjects
{
    Circle circle(double radius, GraphicStyle style, double borderWidth = 1.0)
    {
        auto shape = new Circle(radius, style, borderWidth);
        buildCreated(shape);
        return shape;
    }

    Rectangle rectangle(double width, double height, GraphicStyle style)
    {
        auto shape = new Rectangle(width, height, style);
        buildCreated(shape);
        return shape;
    }
}
