module api.math.geom2.parallelogram2;

import api.math.geom2.vec2 : Vec2f;
import api.math.geom2.line2 : Line2f;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
struct Parallelogram2f
{

    void draw(float width, float height, float angleDeg, bool isInverted, scope bool delegate(size_t, Vec2f) onVertexIsContinue)
    {
        size_t vertexIndex;
        //h = a * sin(angle)
        auto a = height / Math.sinDeg(angleDeg);

        auto offset = Math.sqrt((a ^^ 2) - (height ^^ 2));

        Vec2f leftTop = !isInverted ? Vec2f(offset, 0) :  Vec2f(0, 0);
        if (!onVertexIsContinue(vertexIndex, leftTop))
        {
            return;
        }

        vertexIndex++;

        Vec2f rightTop = !isInverted ? Vec2f(width, 0) : Vec2f(width - offset, 0);
        if (!onVertexIsContinue(vertexIndex, rightTop))
        {
            return;
        }

        vertexIndex++;

        Vec2f rightBottom = !isInverted ? Vec2f(width - offset, height) : Vec2f(width, height);
        if (!onVertexIsContinue(vertexIndex, rightBottom))
        {
            return;
        }

        vertexIndex++;

        Vec2f leftBottom = !isInverted ? Vec2f(0, height) : Vec2f(offset, height);
        onVertexIsContinue(vertexIndex, leftBottom);
    }

}
