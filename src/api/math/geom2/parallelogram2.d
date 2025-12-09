module api.math.geom2.parallelogram2;

import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.line2 : Line2d;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
struct Parallelogram2d
{

    void draw(float width, float height, float angleDeg, bool isInverted, scope bool delegate(size_t, Vec2d) onVertexIsContinue)
    {
        size_t vertexIndex;
        //h = a * sin(angle)
        auto a = height / Math.sinDeg(angleDeg);

        auto offset = Math.sqrt((a ^^ 2) - (height ^^ 2));

        Vec2d leftTop = !isInverted ? Vec2d(offset, 0) :  Vec2d(0, 0);
        if (!onVertexIsContinue(vertexIndex, leftTop))
        {
            return;
        }

        vertexIndex++;

        Vec2d rightTop = !isInverted ? Vec2d(width, 0) : Vec2d(width - offset, 0);
        if (!onVertexIsContinue(vertexIndex, rightTop))
        {
            return;
        }

        vertexIndex++;

        Vec2d rightBottom = !isInverted ? Vec2d(width - offset, height) : Vec2d(width, height);
        if (!onVertexIsContinue(vertexIndex, rightBottom))
        {
            return;
        }

        vertexIndex++;

        Vec2d leftBottom = !isInverted ? Vec2d(0, height) : Vec2d(offset, height);
        onVertexIsContinue(vertexIndex, leftBottom);
    }

}
