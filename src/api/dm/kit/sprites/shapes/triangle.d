module api.dm.kit.sprites.shapes.triangle;

import api.dm.kit.sprites.shapes.shape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.shapes.circle : Circle;
import api.dm.kit.sprites.sprite : Sprite;
import api.math.geom2.vec2: Vec2d;

/**
 * Authors: initkfs
 */
class Triangle : Shape
{
    this(double width, double height, GraphicStyle style)
    {
        super(width, height, style);
    }

    this(double width, double height)
    {
        super(width, height, GraphicStyle.simple);
    }

    override void drawContent()
    {
        import api.dm.kit.graphics.colors.rgba : RGBA;

        Vec2d[3] verts;

        graphics.changeColor(style.lineColor);
        scope(exit){
            graphics.restoreColor;
        }

        const b = boundsAll;

        verts[0] = b.leftBottom;
        verts[1] = b.middleTop;
        verts[2] = b.rightBottom;
        
        if(!style.isFill){
            graphics.polygon(verts[]);
        }else {
            graphics.fillTriangle(verts[0], verts[1], verts[2]);
        }
    }

    override bool intersect(Sprite other)
    {
        //TODO unsafe cast, but fast
        if (auto circle = cast(Circle) other)
        {
            return bounds.intersect(circle.shape);
        }

        return super.intersect(other);
    }
}
