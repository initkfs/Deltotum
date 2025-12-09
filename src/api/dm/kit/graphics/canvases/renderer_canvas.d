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
        graphic.changeColor(rgba);
    }

    RGBA color() => graphic.color;

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

    void lineTo(float endX, float endY)
    {
        graphic.line(x, y, endX, endY);
        moveTo(endX, endY);
    }

    void lineTo(Vec2d pos)
    {
        lineTo(pos.x, pos.y);
    }

    void lineWidth(float width)
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

    void rect(float x, float y, float width, float height)
    {
        graphic.rect(Vec2d(x, y), width, height);
    }

    void fillRect(float x, float y, float width, float height)
    {
        graphic.fillRect(Vec2d(x, y), width, height);
    }

    void fillTriangle(float x1, float y1, float x2, float y2, float x3, float y3)
    {
        graphic.fillTriangle(Vec2d(x1, y1), Vec2d(x2, y2), Vec2d(x3, y3));
    }

    void arc(float xc, float yc, float radius, float angle1, float angle2)
    {

    }

    void scale(float sx, float sy)
    {

    }

    void rotateRad(float angleRad)
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

    void radialGradient(Vec2d innerCenter, Vec2d outerCenter, float innerRadius, float outerRadius, GradientStopPoint[] stopPoints, void delegate() onPattern)
    {
        
    }

}
