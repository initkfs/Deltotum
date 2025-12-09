module api.math.geom2.regular_polygon2;

import api.math.geom2.polygon2 : Polygon2f;

import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

/**
 * Authors: initkfs
 */
struct RegularPolygon2f
{
    size_t sideCount;
    float radius = 0;
    bool isRotateCorrection;

    Polygon2f shape;

    this(size_t sideCount, float radius, bool isRotateCorrection = true)
    {
        assert(sideCount > 0);
        assert(radius > 0);
        this.sideCount = sideCount;
        this.radius = radius;

        this.isRotateCorrection = isRotateCorrection;
    }

    void draw(scope bool delegate(size_t, Vec2f) onIndexVertexIsContinue, float rotateAngle = 0)
    {
        assert(sideCount > 0);
        float segmentAngle = Math.PI2 / sideCount;

        float newRotateAngle = rotateAngle;
        if (isRotateCorrection && newRotateAngle == 0)
        {
            if (sideCount == 3 || (sideCount >= 5 && (sideCount % 2 != 0)))
            {
                rotateAngle = Math.degToRad(270);
            }
            else if (sideCount >= 8 && (sideCount % 2 == 0))
            {
                rotateAngle = Math.degToRad(270 - Math.radToDeg(segmentAngle / 2));
            }
        }

        foreach (i; 0 .. sideCount)
        {
            float angle = rotateAngle != 0 ? (segmentAngle * i + rotateAngle) % Math.PI2 : segmentAngle * i;

            Vec2f polarPos = Vec2f.fromPolarRad(angle, radius);
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
        Vec2f[] points = new Vec2f[](sideCount);
        draw((i, p) { points[i] = p; return true; });
        return points;
    }

}
