module api.dm.kit.sprites.sprites2d.shapes.reqular_polygon;

import api.dm.kit.sprites.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.regular_polygon2 : RegularPolygon2d;

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
        RegularPolygon2d polyDrawer;
    }

    this(double size, GraphicStyle style, size_t sideCount = 6)
    {
        super(size, size, style);
        this.sideCount = sideCount;
    }

    override void create()
    {
        super.create;

        double radius = width / 2;
        polyDrawer = RegularPolygon2d(sideCount, radius);
    }

    override void drawContent()
    {
        import api.dm.kit.graphics.colors.rgba : RGBA;

        graphics.changeColor(style.lineColor);
        scope (exit)
        {
            graphics.restoreColor;
        }
        drawPolygon;
    }

    void drawPolygon()
    {
        auto center = boundsRect.center;
        double firstX;
        double firstY;
        double prevX;
        double prevY;
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
                graphics.line(prevX, prevY, newX, newY);
            }

            prevX = newX;
            prevY = newY;

            return true;
        });

        graphics.line(prevX, prevY, firstX, firstY);
    }
}
