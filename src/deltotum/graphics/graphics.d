module deltotum.graphics.graphics;

import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.graphics.colors.color : Color;
import deltotum.math.vector2d;
import deltotum.graphics.shape.shape_style : ShapeStyle;

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

    void drawPoint(double x, double y, Color color)
    {
        adjustRender(color);
        renderer.drawPoint(toInt(x), toInt(y));
    }

    void drawLines(Vector2D[] points)
    {
        renderer.drawLines(points);
    }

    void drawCircle(double centerX, double centerY, double radius, Color fillColor)
    {
        //Midpoint circle algorithm
        adjustRender(fillColor);

        int xCenter = toInt(centerX);
        int yCenter = toInt(centerY);

        int r = toInt(radius);
        int xOffset;
        int yOffset = r;
        enum decisionParamDelta = 1;
        //5.0 / 4 - r
        int decisionParam = r - decisionParamDelta;
        enum decisionOffset = 2;

        while (yOffset >= xOffset)
        {
            renderer.drawLine(xCenter - yOffset, yCenter + xOffset,
                xCenter + yOffset, yCenter + xOffset);
            renderer.drawLine(xCenter - xOffset, yCenter + yOffset,
                xCenter + xOffset, yCenter + yOffset);
            renderer.drawLine(xCenter - xOffset, yCenter - yOffset,
                xCenter + xOffset, yCenter - yOffset);
            renderer.drawLine(xCenter - yOffset, yCenter - xOffset,
                xCenter + yOffset, yCenter - xOffset);

            if (decisionParam >= decisionOffset * xOffset)
            {
                decisionParam -= decisionOffset * xOffset + decisionParamDelta;
                xOffset++;
            }
            else if (decisionParam < decisionOffset * (r - yOffset))
            {
                decisionParam += decisionOffset * yOffset - decisionParamDelta;
                yOffset--;
            }
            else
            {
                decisionParam += decisionOffset * (yOffset - xOffset - decisionParamDelta);
                yOffset--;
                xOffset++;
            }
        }
    }

    void drawCircle(double centerX, double centerY, double r, ShapeStyle style = ShapeStyle
            .simple)
    {
        if (style.isFill && style.lineWidth == 0)
        {
            drawCircle(centerX, centerY, r, style.fillColor);
            return;
        }

        drawCircle(centerX, centerY, r, style.lineColor);
        drawCircle(centerX, centerY, r - style.lineWidth, style.fillColor);
    }

    void drawRect(double x, double y, double width, double height, Color fillColor)
    {
        adjustRender(fillColor);
        renderer.fillRect(toInt(x), toInt(y), toInt(width), toInt(height));
    }

    void drawRect(double x, double y, double width, double height, ShapeStyle style = ShapeStyle
            .simple)
    {
        if (style.isFill && style.lineWidth == 0)
        {
            drawRect(x, y, width, height, style.fillColor);
            return;
        }

        drawRect(x, y, width, height, style.lineColor);

        const lineWidth = style.lineWidth;
        drawRect(x + lineWidth, y + lineWidth, width - lineWidth * 2, height - lineWidth * 2, style
                .fillColor);
    }
}
