module api.math.geom2.parallelogram2;

import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.line2 : Line2d;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
struct Parallelogram2d
{

    void draw(double width, double height, double angleDeg, scope bool delegate(size_t, Vec2d) onVertexIsContinue)
    {
        size_t vertexIndex;
        //h = a * sin(angle)
        auto a = height / Math.sinDeg(angleDeg);

        auto offset = Math.sqrt((a ^^ 2) - (height ^^ 2));

        Vec2d leftTop = Vec2d(offset, 0);
        if (!onVertexIsContinue(vertexIndex, leftTop))
        {
            return;
        }

        vertexIndex++;

        Vec2d rightTop = Vec2d(width, 0);
        if (!onVertexIsContinue(vertexIndex, rightTop))
        {
            return;
        }

        vertexIndex++;

        Vec2d rightBottom = Vec2d(width - offset, height);
        if (!onVertexIsContinue(vertexIndex, rightBottom))
        {
            return;
        }

        vertexIndex++;

        Vec2d leftBottom = Vec2d(0, height);
        onVertexIsContinue(vertexIndex, leftBottom);
    }

}
