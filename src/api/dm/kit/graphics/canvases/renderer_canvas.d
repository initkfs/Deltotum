module api.dm.kit.graphics.canvases.renderer_canvas;

import api.dm.kit.graphics.canvases.state_canvas : StateCanvas;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas, GradientStopPoint;
import api.dm.kit.graphics.graphic : Graphic;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 */
class RendererCanvas : StateCanvas
{
    protected
    {
        Graphic graphic;
    }

    this(Graphic graphic)
    {
        if (!graphic)
        {
            throw new Exception("Graphic must not be null");
        }
        this.graphic = graphic;
    }

    void color(RGBA rgba)
    {
        graphic.setColor(rgba);
    }

    RGBA color() => graphic.getColor;

    void restoreColor()
    {
        graphic.restoreColor;
    }

    void lineEnd(GraphicCanvas.LineEnd end)
    {

    }

    void lineJoin(GraphicCanvas.LineJoin join)
    {

    }

    void lineTo(double endX, double endY)
    {
        graphic.line(x, y, endX, endY);
        moveTo(endX, endY);
    }

    void lineTo(Vec2d pos)
    {
        lineTo(pos.x, pos.y);
    }

    void lineWidth(double width)
    {

    }

    void stroke()
    {

    }

    void strokePreserve()
    {

    }

    void beginPath()
    {

    }

    void closePath()
    {

    }

    void fill()
    {

    }

    void clear(RGBA color)
    {

    }

    void rect(double x, double y, double width, double height)
    {
        graphic.rect(Vec2d(x, y), width, height);
    }

    void fillRect(double x, double y, double width, double height)
    {
        graphic.fillRect(Vec2d(x, y), width, height);
    }

    void fillTriangle(double x1, double y1, double x2, double y2, double x3, double y3)
    {
        graphic.fillTriangle(Vec2d(x1, y1), Vec2d(x2, y2), Vec2d(x3, y3));
    }

    void arc(double xc, double yc, double radius, double angle1, double angle2)
    {

    }

    void scale(double sx, double sy)
    {

    }

    void rotateRad(double angleRad)
    {

    }

    void save()
    {

    }

    void restore()
    {

    }

    void linearGradient(Vec2d start, Vec2d end, GradientStopPoint[] stopPoints, void delegate() onPattern)
    {

    }

    void radialGradient(Vec2d innerCenter, Vec2d outerCenter, double innerRadius, double outerRadius, GradientStopPoint[] stopPoints, void delegate() onPattern)
    {
        
    }

}
