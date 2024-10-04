module api.dm.kit.graphics.contexts.renderer_graphics_context;

import api.dm.kit.graphics.contexts.state_graphics_context : StateGraphicsContext;
import api.dm.kit.graphics.contexts.graphics_context : GraphicsContext;
import api.dm.kit.graphics.graphics : Graphics;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2d;

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

    void color(RGBA rgba)
    {
        graphics.setColor(rgba);
    }

    void restoreColor()
    {
        graphics.restoreColor;
    }

    void lineEnd(GraphicsContext.LineEnd end){

    }

    void lineJoin(GraphicsContext.LineJoin join) {

    }

    void lineTo(double endX, double endY)
    {
        graphics.line(x, y, endX, endY);
        moveTo(endX, endY);
    }

    void lineTo(Vec2d pos){
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

    void rect(double x, double y, double width, double height){
        graphics.rect(Vec2d(x, y), width, height);
    }

    void fillRect(double x, double y, double width, double height)
    {
        graphics.fillRect(Vec2d(x, y), width, height);
    }

    void fillTriangle(double x1, double y1, double x2, double y2, double x3, double y3){
        graphics.fillTriangle(Vec2d(x1, y1), Vec2d(x2, y2), Vec2d(x3, y3));
    }

    void arc(double xc,double yc, double radius, double angle1, double angle2){

    }

    void scale(double sx, double sy){

    }

    void rotateRad(double angleRad){
        
    }

    void save(){

    }

    void restore(){

    }
}
