module deltotum.kit.factories.creation_shapes;

import deltotum.kit.sprites.factories.sprite_factory : SpriteFactory;

import deltotum.kit.sprites.shapes.shape : Shape;
import deltotum.kit.sprites.shapes.circle : Circle;
import deltotum.kit.sprites.shapes.rectangle : Rectangle;

import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class CreationShapes : SpriteFactory!Shape
{
    override Shape createSprite()
    {
        //TODO default shape-placeholder
        return null;
    }

    Circle circle(double radius, GraphicStyle style)
    {
        auto shape = new Circle(radius, style);
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
