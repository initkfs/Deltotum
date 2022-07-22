module deltotum.graphics.graphics;

import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.graphics.colors.color : Color;

import std.conv : to;

/**
 * Authors: initkfs
 */
class Graphics
{

    private
    {
        SdlRenderer renderer;
    }

    this(SdlRenderer renderer)
    {
        import std.exception : enforce;

        enforce(renderer !is null, "Renderer must not be null");
        this.renderer = renderer;
    }

    //inline?
    private int toInt(double value) pure @safe
    {
        return cast(int) value;
    }

    private void adjustRender(Color color)
    {
        renderer.setRenderDrawColor(color.r, color.g, color.b, color.alphaNorm);
    }

    void drawLine(double startX, double startY, double endX, double endY, Color color = Color.black)
    {
        adjustRender(color);
        renderer.drawLine(toInt(startX), toInt(startY), toInt(endX), toInt(endY));
    }

    void drawRect(double x, double y, double width, double height, Color fillColor = Color.black)
    {
        adjustRender(fillColor);
        renderer.fillRect(toInt(x), toInt(y), toInt(width), toInt(height));
    }

    void drawPoint(double x, double y, Color color)
    {
        adjustRender(color);
        renderer.drawPoint(toInt(x), toInt(y));
    }

    void drawCircle(double centerX, double centerY, double radius, Color color)
    {
        //Midpoint circle algorithm
        const diameter = toInt(radius * 2);
        int xCenter = toInt(centerX);
        int yCenter = toInt(centerY);

        int x = toInt(radius - 1);
        int y;
        int tx = 1;
        int ty = 1;
        int error = to!int(tx - diameter);

        adjustRender(color);

        while (x >= y)
        {
            renderer.drawPoint(xCenter + x, yCenter - y);
            renderer.drawPoint(xCenter + x, yCenter + y);
            renderer.drawPoint(xCenter - x, yCenter - y);
            renderer.drawPoint(xCenter - x, yCenter + y);
            renderer.drawPoint(xCenter + y, yCenter - x);
            renderer.drawPoint(xCenter + y, yCenter + x);
            renderer.drawPoint(xCenter - y, yCenter - x);
            renderer.drawPoint(xCenter - y, yCenter + x);

            if (error <= 0)
            {
                ++y;
                error += ty;
                ty += 2;
            }

            if (error > 0)
            {
                --x;
                tx += 2;
                error += (tx - diameter);
            }
        }
    }
}
