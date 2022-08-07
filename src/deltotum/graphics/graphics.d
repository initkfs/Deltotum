module deltotum.graphics.graphics;

import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.graphics.colors.color : Color;
import deltotum.math.vector2d : Vector2D;
import deltotum.math.math : Math;
import deltotum.graphics.styles.graphic_style: GraphicStyle;
import deltotum.graphics.themes.theme: Theme;


import std.conv : to;

/**
 * Authors: initkfs
 */
class Graphics
{
    @property Theme theme;

    private
    {
        SdlRenderer renderer;
    }

    this(SdlRenderer renderer, Theme theme)
    {
        import std.exception : enforce;

        enforce(renderer !is null, "Renderer must not be null");
        this.renderer = renderer;

        enforce(theme !is null, "Theme must not be null");
        this.theme = theme;
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

    void drawCircle(double centerX, double centerY, double r, GraphicStyle style = GraphicStyle
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

    void drawRect(double x, double y, double width, double height, GraphicStyle style = GraphicStyle
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

    void drawBezier(Vector2D p0, Color color, scope Vector2D delegate(double v) onInterpValue, bool delegate(
            Vector2D) onPoint = null)
    {
        adjustRender(color);
        enum delta = 0.01; //100 segments
        Vector2D start = p0;
        //TODO exact comparison of doubles?
        for (double i = 0; i < 1; i += delta)
        {
            auto end = onInterpValue(i);
            if (onPoint !is null && !onPoint(end))
            {
                start = end;
                continue;
            }
            renderer.drawLine(toInt(start.x), toInt(start.y), toInt(end.x), toInt(end.y));
            start = end;
        }
    }

    void drawBezier(Vector2D p0, Vector2D p1, Vector2D p2, Color color, bool delegate(
            Vector2D) onPoint = null)
    {
        drawBezier(p0, color, (t) { return bezierInterp(p0, p1, p2, t); }, onPoint);
    }

    void drawBezier(Vector2D p0, Vector2D p1, Vector2D p2, Vector2D p3, Color color, bool delegate(
            Vector2D) onPoint = null)
    {
        drawBezier(p0, color, (t) { return bezierInterp(p0, p1, p2, p3, t); }, onPoint);
    }

    private Vector2D bezierInterp(Vector2D p0, Vector2D p1, Vector2D p2, Vector2D p3, double t) @nogc nothrow pure @safe
    {
        const dt = 1 - t;
        Vector2D p0p1 = p0.scale(dt).add(p1.scale(t));
        Vector2D p1p2 = p1.scale(dt).add(p2.scale(t));
        Vector2D p2p3 = p2.scale(dt).add(p3.scale(t));
        Vector2D p0p1p2 = p0p1.scale(dt).add(p1p2.scale(t));
        Vector2D p1p2p3 = p1p2.scale(dt).add(p2p3.scale(t));
        Vector2D result = p0p1p2.scale(dt).add(p1p2p3.scale(t));

        return result;
    }

    private Vector2D bezierInterp(Vector2D p0, Vector2D p1, Vector2D p2, double t) @nogc nothrow pure @safe
    {
        const dt = 1 - t;
        Vector2D p0p1 = p0.scale(dt).add(p1.scale(t));
        Vector2D p1p2 = p1.scale(dt).add(p2.scale(t));
        Vector2D result = p0p1.scale(dt).add(p1p2.scale(t));
        return result;
    }
}
