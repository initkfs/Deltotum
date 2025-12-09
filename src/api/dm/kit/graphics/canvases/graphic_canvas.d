module api.dm.kit.graphics.canvases.graphic_canvas;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2f;

struct GradientStopPoint
{
    float offset = 0;
    RGBA color;
}

/**
 * Authors: initkfs
 */
interface GraphicCanvas
{
    enum LineEnd
    {
        butt,
        round,
        square
    }

    enum LineJoin
    {
        miter,
        round,
        bevel
    }

    void beginPath();
    void closePath();

    bool isPointInPath(float x, float y);

    void color(RGBA rgba);
    RGBA color();
    void restoreColor();
    void clear(RGBA color);

    void lineWidth(float width);

    void save();
    void restore();
    void reset();

    void translate(float x, float y);
    void scale(float sx, float sy);
    void rotateRad(float angleRad);

    void lineEnd(LineEnd end);
    void lineJoin(LineJoin join);

    void moveTo(float x, float y);
    void moveTo(Vec2f pos);

    void lineTo(float x, float y);
    void lineTo(Vec2f pos);

    void stroke();
    void strokePreserve();
    void fill();
    void fillPreserve();

    void clip();

    void rect(float x, float y, float width, float height);
    void fillRect(float x, float y, float width, float height);
    void clearRect(float x, float y, float width, float height);

    void fillTriangle(float x1, float y1, float x2, float y2, float x3, float y3);

    void arc(float xc, float yc, float radius, float angle1Rad, float angle2Rad);

    void bezierCurveTo(float x1, float y1, float x2, float y2, float x3, float y3);

    void linearGradient(Vec2f start, Vec2f end, GradientStopPoint[] stopPoints, void delegate() onPattern);
    void radialGradient(Vec2f innerCenter, Vec2f outerCenter, float innerRadius, float outerRadius, GradientStopPoint[] stopPoints, void delegate() onPattern);
}
