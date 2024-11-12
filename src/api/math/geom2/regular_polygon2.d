module api.math.geom2.regular_polygon2;

import api.math.geom2.polygon2 : Polygon2d;

import api.math.geom2.vec2 : Vec2d;
import Math = api.math;
import api.math.geom2.polybools.polybool;

/**
 * Authors: initkfs
 */
struct RegularPolygon2d
{
    size_t sideCount;
    double radius = 0;

    Polygon2d shape;

    this(size_t sideCount, double radius)
    {
        assert(sideCount > 0);
        assert(radius > 0);
        this.sideCount = sideCount;
        this.radius = radius;
    }

    void draw(scope bool delegate(size_t, Vec2d) onIndexVertexIsContinue)
    {
        assert(sideCount > 0);
        const segment = Math.PI2 / sideCount;

        foreach (i; 0 .. sideCount)
        {
            double angle = segment * i;

            Vec2d polarPos = Vec2d.fromPolarRad(angle, radius);
            if (!onIndexVertexIsContinue(i, polarPos))
            {
                return;
            }
        }
    }

    void create()
    {
        shape = Polygon2d(createPoints);
    }

    Vec2d[] createPoints()
    {
        Vec2d[] points = new Vec2d[](sideCount);
        draw((i, p) { points[i] = p; return true; });
        return points;
    }

}
