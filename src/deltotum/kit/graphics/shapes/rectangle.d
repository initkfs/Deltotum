module deltotum.kit.graphics.shapes.rectangle;

import deltotum.kit.graphics.shapes.shape;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.graphics.shapes.circle: Circle;
import deltotum.kit.sprites.sprite: Sprite;

/**
 * Authors: initkfs
 */
class Rectangle : Shape
{
    this(double width, double height, GraphicStyle style)
    {
        super(width, height, style);
    }

    this(double width, double height)
    {
        super(width, height);
    }

    override void drawContent()
    {
        import deltotum.kit.graphics.colors.rgba : RGBA;

        if (style.isFill)
        {
            graphics.fillRect(x, y, width, height, style.fillColor);
        }
        else
        {
            graphics.drawRect(x, y, width, height, style.lineColor);
        }
    }

    override bool intersect(Sprite other)
    {
        //TODO remove cast
        if (auto circle = cast(Circle) other)
        {
            return bounds.intersect(circle.shape);
        }
        
        return super.intersect(other);
    }

    // override double width(){
    //     return super.width;
    // }

    // override void width(double v){
    //     super.width(v);
    //     import std;
    //     writefln("Rectangle w: %s", v);
    // }
}
