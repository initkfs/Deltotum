module api.dm.kit.sprites2d.shapes.reqular_poly;

import api.dm.kit.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.graphics.styles.gstyle : GStyle;
import api.math.geom2.regular_poly2 : RegularPoly2f;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class RegularPoly : Shape2d
{
    bool isFlat = true;

    protected
    {
        size_t sideCount;
        RegularPoly2f polyDrawer;
    }

    this(float size, GStyle style, size_t sideCount = 6)
    {
        super(size, size, style);
        this.sideCount = sideCount;
    }

    override void create()
    {
        super.create;

        float radius = width / 2;
        polyDrawer = RegularPoly2f(sideCount, radius);
    }

    override void drawContent()
    {
        import api.dm.kit.graphics.colors.rgba : RGBA;

        graphic.color(style.lineColor);
        scope (exit)
        {
            graphic.restoreColor;
        }
        drawPoly;
    }

    void drawPoly()
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
