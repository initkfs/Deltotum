module api.math.geom2.parallelogram2;

import api.math.geom2.vec2 : Vec2f;
import api.math.geom2.line2 : Line2f;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
struct Parallelogram2f
{

    void draw(float width, float height, float angleDeg, bool isInverted, float strokeWidth, scope bool delegate(size_t, Vec2f) onVertexIsContinue, float margin = 1)
    {
        size_t vertexIndex;
        //h = a * sin(angle)
        auto a = height / Math.sinDeg(angleDeg);

        const halfLine = strokeWidth / 2 + margin;
        
        auto offset = Math.sqrt((a ^^ 2) - (height ^^ 2));

        Vec2f leftTop = !isInverted ? Vec2f(offset + halfLine, halfLine) :  Vec2f(halfLine, halfLine);
        if (!onVertexIsContinue(vertexIndex, leftTop))
        {
            return;
        }

        vertexIndex++;

        Vec2f rightTop = !isInverted ? Vec2f(width - halfLine, halfLine) : Vec2f(width - offset - halfLine, halfLine);
        if (!onVertexIsContinue(vertexIndex, rightTop))
        {
            return;
        }

        vertexIndex++;

        Vec2f rightBottom = !isInverted ? Vec2f(width - offset - halfLine, height - halfLine) : Vec2f(width - halfLine, height - halfLine);
        if (!onVertexIsContinue(vertexIndex, rightBottom))
        {
            return;
        }

        vertexIndex++;

        Vec2f leftBottom = !isInverted ? Vec2f(halfLine, height - halfLine) : Vec2f(offset + halfLine, height - halfLine);
        onVertexIsContinue(vertexIndex, leftBottom);
    }

}
