module api.math.geom2.star_polygon2;

import api.math.geom2.polygon2 : Polygon2d;

import api.math.geom2.vec2 : Vec2d;
import Math = api.math;

/**
 * Authors: initkfs
 */
struct StarPolygon2d
{
    size_t spikeCount;
    double outerRadius = 0;
    double innerRadius = 0;

    Polygon2d shape;

    this(size_t spikeCount, double innerRadius, double outerRadius)
    {
        assert(spikeCount > 0);
        assert(outerRadius > 0);

        this.spikeCount = spikeCount;
        this.innerRadius = innerRadius;
        this.outerRadius = outerRadius;
    }

    void draw(scope bool delegate(size_t, Vec2d) onIndexVertexIsContinue)
    {
        assert(spikeCount > 0);
        const angleRad = Math.PI / spikeCount;

        foreach (i; 0 .. (2 * spikeCount))
        {
            const radius = ((i % 2) != 0) ? outerRadius : innerRadius;
            const polarPos = Vec2d.fromPolarRad(i * angleRad, radius);
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
        assert(spikeCount > 0);
        Vec2d[] points = new Vec2d[](2 * spikeCount);
        draw((i, p) { points[i] = p; return true; });
        return points;
    }

}
