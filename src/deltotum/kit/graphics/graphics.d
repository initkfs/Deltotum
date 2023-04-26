module deltotum.kit.graphics.graphics;

import deltotum.core.applications.components.units.services.loggable_unit;

import deltotum.sys.sdl.sdl_renderer : SdlRenderer;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.math.vector2d : Vector2d;
import math = deltotum.math;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.graphics.themes.theme : Theme;

import std.logger.core : Logger;
import std.conv : to;

/**
 * Authors: initkfs
 */
class Graphics : LoggableUnit
{
    Theme theme;

    //private
    //{
        SdlRenderer renderer;
   // }

    this(Logger logger, SdlRenderer renderer, Theme theme)
    {
        super(logger);

        import std.exception : enforce;

        enforce(renderer !is null, "Renderer must not be null");
        this.renderer = renderer;

        enforce(theme !is null, "Theme must not be null");
        this.theme = theme;
    }

    //inline?
    private int toInt(double value) pure @safe const nothrow
    {
        return cast(int) value;
    }

    private void adjustRender(RGBA color)
    {
        if (const err = renderer.setRenderDrawColor(color.r, color.g, color.b, color.alphaNorm))
        {
            logger.errorf("Adjust render error. %s", err);
        }
    }

    void drawLine(double startX, double startY, double endX, double endY)
    {
        if (const err = renderer.drawLine(toInt(startX), toInt(startY), toInt(endX), toInt(endY)))
        {
            logger.errorf("Line drawing error. %s", err);
        }
    }

    void drawLine(Vector2d start, Vector2d end, RGBA color = RGBA.black)
    {
        drawLine(start.x, start.y, end.x, end.y, color);
    }

    void drawLine(double startX, double startY, double endX, double endY, RGBA color = RGBA.black)
    {
        adjustRender(color);
        drawLine(startX, startY, endX, endY);
    }

    void drawPoint(double x, double y, RGBA color)
    {
        adjustRender(color);
        if (const err = renderer.drawPoint(toInt(x), toInt(y)))
        {
            logger.errorf("Point drawing error. %s", err);
        }
    }

    void drawPoints(Vector2d[] points, RGBA color)
    {
        adjustRender(color);
        foreach (p; points)
        {
            drawPoint(p.x, p.y, color);
        }
    }

    void drawLines(Vector2d[] points, RGBA color)
    {
        adjustRender(color);
        if (const err = renderer.drawLines(points))
        {
            logger.errorf("Lines drawing error. %s", err);
        }
    }

    Vector2d[] linePoints(double startX, double startY, double endX, double endY) const nothrow pure @safe
    {
        return linePoints(toInt(startX), toInt(startY), toInt(endX), toInt(endY));
    }

    Vector2d[] linePoints(int startX, int startY, int endX, int endY) const nothrow pure @safe
    {
        //Bresenham algorithm
        import math = deltotum.math;

        Vector2d[] points;

        immutable deltaX = endX - startX;
        immutable deltaY = endY - startY;

        enum delta1 = 1;
        enum delta1Neg = -1;

        int dx1 = 0, dy1 = 0, dx2 = 0, dy2 = 0;
        if (deltaX < 0)
        {
            dx1 = delta1Neg;
            dx2 = delta1Neg;
        }
        else if (deltaX > 0)
        {
            dx1 = delta1;
            dx2 = delta1;
        }

        if (deltaY < 0)
        {
            dy1 = delta1Neg;
        }
        else if (deltaY > 0)
        {
            dy1 = delta1;
        }

        int longestLen = math.abs(deltaX);
        int shortestLen = math.abs(deltaY);

        if (longestLen < shortestLen)
        {
            longestLen = math.abs(deltaY);
            shortestLen = math.abs(deltaX);
            if (deltaY < 0)
            {
                dy2 = delta1Neg;
            }
            else if (deltaY > 0)
            {
                dy2 = delta1;
            }

            dx2 = 0;
        }

        int shortestLen2 = shortestLen * 2;
        int longestLen2 = longestLen * 2;
        int num = 0;
        for (int i = 0; i <= longestLen; i++)
        {
            points ~= Vector2d(startX, startY);
            num += shortestLen2;
            if (num > longestLen)
            {
                num -= longestLen2;
                startX += dx1;
                startY += dy1;
            }
            else
            {
                startX += dx2;
                startY += dy2;
            }
        }

        return points;
    }

    Vector2d[] circlePoints(int centerX, int centerY, int radius) const nothrow pure @safe
    {
        //Bresenham algorithm
        import math = deltotum.math;

        Vector2d[] points;

        int x = 0;
        int y = radius;
        int delta = 1 - 2 * radius;
        int error = 0;
        while (y >= x)
        {
            points ~= Vector2d(centerX + x, centerY + y);
            points ~= Vector2d(centerX + x, centerY - y);
            points ~= Vector2d(centerX - x, centerY + y);
            points ~= Vector2d(centerX - x, centerY - y);
            points ~= Vector2d(centerX + y, centerY + x);
            points ~= Vector2d(centerX + y, centerY - x);
            points ~= Vector2d(centerX - y, centerY + x);
            points ~= Vector2d(centerX - y, centerY - x);
            error = 2 * (delta + y) - 1;
            if ((delta < 0) && (error <= 0))
            {
                delta += 2 * ++x + 1;
                continue;
            }

            if ((delta > 0) && (error > 0))
            {
                delta -= 2 * --y + 1;
                continue;
            }

            delta += 2 * (++x - --y);
        }

        return points;
    }

    void drawTriangle(Vector2d v1, Vector2d v2, Vector2d v3, RGBA fillColor)
    {
        scope Vector2d[] side1LinePoints = linePoints(v1.x, v1.y, v2.x, v2.y);
        scope Vector2d[] side2LinePoints = linePoints(v3.x, v3.y, v2.x, v2.y);
        fillPolyLines(side1LinePoints, side2LinePoints, fillColor);
    }

    void drawCircle(double centerX, double centerY, double radius, RGBA fillColor)
    {
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
            drawLine(xCenter - yOffset, yCenter + xOffset,
                xCenter + yOffset, yCenter + xOffset);
            drawLine(xCenter - xOffset, yCenter + yOffset,
                xCenter + xOffset, yCenter + yOffset);
            drawLine(xCenter - xOffset, yCenter - yOffset,
                xCenter + xOffset, yCenter - yOffset);
            drawLine(xCenter - yOffset, yCenter - xOffset,
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

    void drawRect(double x, double y, double width, double height, RGBA fillColor)
    {
        adjustRender(fillColor);
        if (const err = renderer.fillRect(toInt(x), toInt(y), toInt(width), toInt(height)))
        {
            logger.errorf("Draw rect error. %s", err);
        }
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

    void drawBezier(Vector2d p0, RGBA color, scope Vector2d delegate(double v) onInterpValue, bool delegate(
            Vector2d) onPoint = null)
    {
        adjustRender(color);
        enum delta = 0.01; //100 segments
        Vector2d start = p0;
        //TODO exact comparison of doubles?
        for (double i = 0; i < 1; i += delta)
        {
            auto end = onInterpValue(i);
            if (onPoint !is null && !onPoint(end))
            {
                start = end;
                continue;
            }
            drawLine(toInt(start.x), toInt(start.y), toInt(end.x), toInt(end.y));
            start = end;
        }
    }

    void drawBezier(Vector2d p0, Vector2d p1, Vector2d p2, RGBA color, bool delegate(
            Vector2d) onPoint = null)
    {
        drawBezier(p0, color, (t) { return bezierInterp(p0, p1, p2, t); }, onPoint);
    }

    void drawBezier(Vector2d p0, Vector2d p1, Vector2d p2, Vector2d p3, RGBA color, bool delegate(
            Vector2d) onPoint = null)
    {
        drawBezier(p0, color, (t) { return bezierInterp(p0, p1, p2, p3, t); }, onPoint);
    }

    private Vector2d bezierInterp(Vector2d p0, Vector2d p1, Vector2d p2, Vector2d p3, double t) @nogc nothrow pure @safe
    {
        const dt = 1 - t;
        Vector2d p0p1 = p0.scale(dt).add(p1.scale(t));
        Vector2d p1p2 = p1.scale(dt).add(p2.scale(t));
        Vector2d p2p3 = p2.scale(dt).add(p3.scale(t));
        Vector2d p0p1p2 = p0p1.scale(dt).add(p1p2.scale(t));
        Vector2d p1p2p3 = p1p2.scale(dt).add(p2p3.scale(t));
        Vector2d result = p0p1p2.scale(dt).add(p1p2p3.scale(t));

        return result;
    }

    private Vector2d bezierInterp(Vector2d p0, Vector2d p1, Vector2d p2, double t) @nogc nothrow pure @safe
    {
        const dt = 1 - t;
        Vector2d p0p1 = p0.scale(dt).add(p1.scale(t));
        Vector2d p1p2 = p1.scale(dt).add(p2.scale(t));
        Vector2d result = p0p1.scale(dt).add(p1p2.scale(t));
        return result;
    }

    bool fillPolyLines(Vector2d[] vertexStart, Vector2d[] vertexEnd, RGBA fillColor)
    {
        foreach (i, vStart; vertexStart)
        {
            if (i >= vertexEnd.length)
            {
                break;
            }
            const vEnd = vertexEnd[i];
            drawLine(vStart, vEnd, fillColor);
        }
        return true;
    }
}
