module api.dm.kit.graphics.canvases.graphic_canvas;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2d;

struct GradientStopPoint
{
    double offset = 0;
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

    bool isPointInPath(double x, double y);

    void color(RGBA rgba);
    RGBA color();
    void restoreColor();
    void clear(RGBA color);

    void lineWidth(double width);

    void save();
    void restore();
    void reset();

    void translate(double x, double y);
    void scale(double sx, double sy);
    void rotateRad(double angleRad);

    void lineEnd(LineEnd end);
    void lineJoin(LineJoin join);

    void moveTo(double x, double y);
    void moveTo(Vec2d pos);

    void lineTo(double x, double y);
    void lineTo(Vec2d pos);

    void stroke();
    void strokePreserve();
    void fill();
    void fillPreserve();

    void clip();

    void rect(double x, double y, double width, double height);
    void fillRect(double x, double y, double width, double height);
    void clearRect(double x, double y, double width, double height);

    void fillTriangle(double x1, double y1, double x2, double y2, double x3, double y3);

    void arc(double xc, double yc, double radius, double angle1Rad, double angle2Rad);

    void bezierCurveTo(double x1, double y1, double x2, double y2, double x3, double y3);

    void linearGradient(Vec2d start, Vec2d end, GradientStopPoint[] stopPoints, void delegate() onPattern);
    void radialGradient(Vec2d innerCenter, Vec2d outerCenter, double innerRadius, double outerRadius, GradientStopPoint[] stopPoints, void delegate() onPattern);
}
