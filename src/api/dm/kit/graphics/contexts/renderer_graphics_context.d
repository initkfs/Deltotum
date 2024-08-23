module api.dm.kit.graphics.contexts.renderer_graphics_context;

import api.dm.kit.graphics.contexts.state_graphics_context : StateGraphicsContext;
import api.dm.kit.graphics.contexts.graphics_context : GraphicsContext;
import api.dm.kit.graphics.graphics : Graphics;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.vector2 : Vector2;

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

    void setLineEnd(GraphicsContext.LineEnd end){

    }

    void setLineJoin(GraphicsContext.LineJoin join) {

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

    void beginPath(){
        
    }

    void closePath()
    {

    }

    void fill()
    {

    }

    void clear(RGBA color){
        
    }

    void fillRect(double x, double y, double width, double height)
    {
        graphics.fillRect(Vector2(x, y), width, height);
    }

    void fillTriangle(double x1, double y1, double x2, double y2, double x3, double y3){
        graphics.fillTriangle(Vector2(x1, y1), Vector2(x2, y2), Vector2(x3, y3));
    }

    void arc(double xc,double yc, double radius, double angle1, double angle2){

    }
}
