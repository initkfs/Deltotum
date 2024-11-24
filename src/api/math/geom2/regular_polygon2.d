module api.math.geom2.regular_polygon2;

import api.math.geom2.polygon2 : Polygon2d;

import api.math.geom2.vec2 : Vec2d;
import Math = api.math;

/**
 * Authors: initkfs
 */
struct RegularPolygon2d
{
    size_t sideCount;
    double radius = 0;
    bool isRotateCorrection;

    Polygon2d shape;

    this(size_t sideCount, double radius, bool isRotateCorrection = true)
    {
        assert(sideCount > 0);
        assert(radius > 0);
        this.sideCount = sideCount;
        this.radius = radius;

        this.isRotateCorrection = isRotateCorrection;
    }

    void draw(scope bool delegate(size_t, Vec2d) onIndexVertexIsContinue, double rotateAngle = 0)
    {
        assert(sideCount > 0);
        double segmentAngle = Math.PI2 / sideCount;

        double newRotateAngle = rotateAngle;
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
            double angle = rotateAngle != 0 ? (segmentAngle * i + rotateAngle) % Math.PI2 : segmentAngle * i;

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
