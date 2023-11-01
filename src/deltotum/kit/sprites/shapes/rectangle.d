module deltotum.kit.sprites.shapes.rectangle;

import deltotum.kit.sprites.shapes.shape;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.sprites.shapes.circle : Circle;
import deltotum.kit.sprites.sprite : Sprite;

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

        const lineWidth = style.lineWidth;
        graphics.rect(x, y, width, height, style.lineColor);
        if (style.isFill)
        {
            graphics.fillRect(x + lineWidth, y + lineWidth, width - lineWidth * 2, height - lineWidth * 2, style.fillColor);
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
