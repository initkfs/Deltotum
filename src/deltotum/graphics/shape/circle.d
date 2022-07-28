module deltotum.graphics.shape.circle;

import deltotum.graphics.shape.shape;
import deltotum.graphics.shape.shape_style : ShapeStyle;

/**
 * Authors: initkfs
 */
class Circle : Shape
{
    @property double radius = 0;

    this(double radius, ShapeStyle* style, double borderWidth = 1.0)
    {
        super(radius * 2 + borderWidth, radius * 2 + borderWidth, style);
        this.radius = radius;
    }

    override void create()
    {
        super.create;
        window.renderer.setRendererTarget(texture.getStruct);
        graphics.drawCircle(width / 2, height / 2, radius, *style);
        window.renderer.resetRendererTarget;
    }
}
