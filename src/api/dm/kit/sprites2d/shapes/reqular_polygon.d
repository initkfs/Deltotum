module api.dm.kit.sprites2d.shapes.reqular_polygon;

import api.dm.kit.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.regular_polygon2 : RegularPolygon2f;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class RegularPolygon : Shape2d
{
    bool isFlat = true;

    protected
    {
        size_t sideCount;
        RegularPolygon2f polyDrawer;
    }

    this(float size, GraphicStyle style, size_t sideCount = 6)
    {
        super(size, size, style);
        this.sideCount = sideCount;
    }

    override void create()
    {
        super.create;

        float radius = width / 2;
        polyDrawer = RegularPolygon2f(sideCount, radius);
    }

    override void drawContent()
    {
        import api.dm.kit.graphics.colors.rgba : RGBA;

        graphic.color(style.lineColor);
        scope (exit)
        {
            graphic.restoreColor;
        }
        drawPolygon;
    }

    void drawPolygon()
    {
        auto center = boundsRect.center;
        float firstX;
        float firstY;
        float prevX;
        float prevY;
        polyDrawer.draw((i, p) {

            const newX = center.x + p.x;
            const newY = center.y + p.y;

            if (i == 0)
            {
                firstX = newX;
                firstY = newY;
            }
            else
            {
                graphic.line(prevX, prevY, newX, newY);
            }

            prevX = newX;
            prevY = newY;

            return true;
        });

        graphic.line(prevX, prevY, firstX, firstY);
    }
}
