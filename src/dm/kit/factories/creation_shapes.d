module dm.kit.factories.creation_shapes;

import dm.kit.sprites.factories.sprite_factory : SpriteFactory;

import dm.kit.sprites.shapes.shape : Shape;
import dm.kit.sprites.shapes.circle : Circle;
import dm.kit.sprites.shapes.rectangle : Rectangle;

import dm.kit.graphics.styles.graphic_style : GraphicStyle;

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
