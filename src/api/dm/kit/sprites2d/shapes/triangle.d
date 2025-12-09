module api.dm.kit.sprites2d.shapes.triangle;

import api.dm.kit.sprites2d.shapes.shape2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.shapes.circle : Circle;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.vec2: Vec2f;

/**
 * Authors: initkfs
 */
class Triangle : Shape2d
{
    this(float width, float height, GraphicStyle style)
    {
        super(width, height, style);
    }

    this(float width, float height)
    {
        super(width, height, GraphicStyle.simple);
    }

    override void drawContent()
    {
        import api.dm.kit.graphics.colors.rgba : RGBA;

        Vec2f[3] verts;

        graphic.color(style.lineColor);
        scope(exit){
            graphic.restoreColor;
        }

        const b = boundsPoly;

        verts[0] = b.leftBottom;
        verts[1] = b.middleTop;
        verts[2] = b.rightBottom;
        
        if(!style.isFill){
            graphic.polygon(verts[]);
        }else {
            graphic.fillTriangle(verts[0], verts[1], verts[2]);
        }
    }

    override bool intersect(Sprite2d other)
    {
        //TODO unsafe cast, but fast
        if (auto circle = cast(Circle) other)
        {
            return boundsRect.intersect(circle.shape);
        }

        return super.intersect(other);
    }
}
