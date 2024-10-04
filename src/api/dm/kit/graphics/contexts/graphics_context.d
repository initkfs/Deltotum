module api.dm.kit.graphics.contexts.graphics_context;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.vec2 : Vec2d;

/**
 * Authors: initkfs
 */
interface GraphicsContext
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
}
