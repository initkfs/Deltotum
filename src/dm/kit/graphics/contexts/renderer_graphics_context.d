module dm.kit.graphics.contexts.renderer_graphics_context;

import dm.kit.graphics.contexts.state_graphics_context : StateGraphicsContext;
import dm.kit.graphics.graphics : Graphics;
import dm.kit.graphics.colors.rgba : RGBA;

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

    void stroke()
    {

    }

    void fill()
    {

    }
}
