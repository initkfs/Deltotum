module api.math.geom2.star_polygon2;

import api.math.geom2.polygon2 : Polygon2f;

import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

/**
 * Authors: initkfs
 */
struct StarPolygon2f
{
    size_t spikeCount;
    float outerRadius = 0;
    float innerRadius = 0;

    Polygon2f shape;

    this(size_t spikeCount, float innerRadius, float outerRadius)
    {
        assert(spikeCount > 0);
        assert(outerRadius > 0);

        this.spikeCount = spikeCount;
        this.innerRadius = innerRadius;
        this.outerRadius = outerRadius;
    }

    void draw(scope bool delegate(size_t, Vec2f) onIndexVertexIsContinue)
    {
        assert(spikeCount > 0);
        const angleRad = Math.PI / spikeCount;

        foreach (i; 0 .. (2 * spikeCount))
        {
            const radius = ((i % 2) != 0) ? outerRadius : innerRadius;
            const polarPos = Vec2f.fromPolarRad(i * angleRad, radius);
            if (!onIndexVertexIsContinue(i, polarPos))
            {
                return;
            }
        }
    }

    void create()
    {
        shape = Polygon2f(createPoints);
    }

    Vec2f[] createPoints()
    {
        assert(spikeCount > 0);
        Vec2f[] points = new Vec2f[](2 * spikeCount);
        draw((i, p) { points[i] = p; return true; });
        return points;
    }

}
