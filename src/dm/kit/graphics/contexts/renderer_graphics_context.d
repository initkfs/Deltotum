module dm.kit.graphics.contexts.renderer_graphics_context;

import dm.kit.graphics.contexts.state_graphics_context : StateGraphicsContext;
import dm.kit.graphics.graphics : Graphics;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.math.vector2 : Vector2;

/**
 * Authors: initkfs
 */
class RendererGraphicsContext : StateGraphicsContext
{
    protected
    {
        Graphics graphics;
    }

    this(Graphics graphics)
    {
        if (!graphics)
        {
            throw new Exception("Graphics must not be null");
        }
        this.graphics = graphics;
    }

    void setColor(RGBA rgba)
    {
        graphics.setColor(rgba);
    }

    void restoreColor()
    {
        graphics.restoreColor;
    }

    void lineTo(double endX, double endY)
    {
        graphics.line(x, y, endX, endY);
        moveTo(endX, endY);
    }

    void setLineWidth(double width)
    {

    }

    void stroke()
    {

    }

    void strokePreserve()
    {

    }

    void closePath()
    {

    }

    void fill()
    {

    }

    void fillRect(double x, double y, double width, double height)
    {
        graphics.fillRect(Vector2(x, y), width, height);
    }

    void fillTriangle(double x1, double y1, double x2, double y2, double x3, double y3){
        graphics.fillTriangle(Vector2(x2, y1), Vector2(x2, y2), Vector2(x3, y3));
    }
}
