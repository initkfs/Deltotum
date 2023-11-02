module deltotum.kit.graphics.graphics;

import deltotum.core.apps.units.services.loggable_unit;

import deltotum.sys.sdl.sdl_renderer : SdlRenderer;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.math.vector2d : Vector2d;
import math = deltotum.math;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.graphics.themes.theme : Theme;
import deltotum.kit.sprites.textures.texture : Texture;

import deltotum.math.geom.flip : Flip;
import deltotum.math.shapes.rect2d : Rect2d;

import std.logger.core : Logger;
import std.conv : to;

//TODO remove
import deltotum.sys.sdl.sdl_texture : SdlTexture;
import deltotum.sys.sdl.sdl_surface : SdlSurface;

/**
 * Authors: initkfs
 */
class Graphics : LoggableUnit
{
    //TODO move to gui module
    Theme theme;

    //TODO remove
    static RGBA defaultColor = RGBA.red;

    protected
    {
        RGBA prevColor;
        SdlRenderer renderer;
    }

    //TODO ComTexture, ComSurface;
    //these factories are added for performance to avoid unnecessary wrapping in the object.
    SdlTexture delegate() comTextureFactory;
    SdlSurface delegate() comSurfaceFactory;

    this(Logger logger, SdlRenderer renderer, Theme theme)
    {
        super(logger);

        import std.exception : enforce;

        //TODO opengl
        // enforce(renderer !is null, "Renderer must not be null");
        this.renderer = renderer;

        enforce(theme !is null, "Theme must not be null");
        this.theme = theme;
    }

    //TODO remove sdl api
    SdlTexture newComTexture()
    {
        assert(comTextureFactory);
        auto texture = comTextureFactory();
        return texture;
    }

    //TODO remove sdl api
    SdlSurface newComSurface()
    {
        assert(comSurfaceFactory);
        auto surface = comSurfaceFactory();
        return surface;
    }

    pragma(inline, true)
    private int toInt(double value) pure @safe const nothrow
    {
        return cast(int) value;
    }

    Rect2d getClip()
    {
        Rect2d clip;
        if (const err = renderer.getClipRect(clip))
        {
            logger.error("Error receiving clipping. ", err.toString);
        }
        return clip;
    }

    void setClip(Rect2d clipRect)
    {
        if (const err = renderer.setClipRect(clipRect))
        {
            logger.error("Error setting clipping. ", err.toString);
        }
    }

    void removeClip()
    {
        if (const err = renderer.removeClipRect)
        {
            logger.error("Error removing clipping. ", err.toString);
        }
    }

    RGBA changeColor(RGBA color = defaultColor)
    {
        ubyte r, g, b, a;
        if (const err = renderer.getRenderDrawColor(r, g, b, a))
        {
            logger.errorf("Error getting current renderer color");
            return prevColor;
        }

        const aNorm = (cast(double) a) / ubyte.max;
        prevColor = RGBA(r, g, b, aNorm);

        setColor(color);

        return prevColor;
    }

    void setColor(RGBA color)
    {
        if (const err = renderer.setRenderDrawColor(color.r, color.g, color.b, color.aNorm))
        {
            logger.errorf("Adjust render error. %s", err);
        }
    }

    void restoreColor()
    {
        setColor(prevColor);
    }

    void line(double startX, double startY, double endX, double endY)
    {
        if (const err = renderer.line(toInt(startX), toInt(startY), toInt(endX), toInt(endY)))
        {
            logger.error("Line drawing error. ", err);
        }
    }

    void line(Vector2d start, Vector2d end)
    {
        line(start.x, start.y, end.x, end.y);
    }

    void line(Vector2d start, Vector2d end, RGBA color = defaultColor)
    {
        line(start.x, start.y, end.x, end.y, color);
    }

    void line(double startX, double startY, double endX, double endY, RGBA color = defaultColor)
    {
        changeColor(color);
        scope (exit)
        {
            restoreColor;
        }
        line(startX, startY, endX, endY);
    }

    void lines(Vector2d[] points)
    {
        if (const err = renderer.lines(points))
        {
            logger.errorf("Lines drawing error. %s", err);
        }
    }

    void lines(Vector2d[] points, RGBA color = defaultColor)
    {
        changeColor(color);
        scope (exit)
        {
            restoreColor;
        }

        lines(points);
    }

    void point(double x, double y)
    {
        if (const err = renderer.point(toInt(x), toInt(y)))
        {
            logger.errorf("Point drawing error. %s", err);
        }
    }

    void point(Vector2d p)
    {
        point(p.x, p.y);
    }

    void point(double x, double y, RGBA color = defaultColor)
    {
        changeColor(color);
        scope (exit)
        {
            restoreColor;
        }

        point(x, y);
    }

    void point(Vector2d p, RGBA color = defaultColor)
    {
        point(p.x, p.y, color);
    }

    void points(Vector2d[] points)
    {
        foreach (p; points)
        {
            point(p.x, p.y);
        }
    }

    void points(Vector2d[] p, RGBA color = defaultColor)
    {
        changeColor(color);
        scope (exit)
        {
            restoreColor;
        }

        points(p);
    }

    Vector2d[] linePoints(Vector2d start, Vector2d end)
    {
        return linePoints(start.x, start.y, end.x, end.y);
    }

    Vector2d[] linePoints(double startXPos, double startYPos, double endXPos, double endYPos)
    {
        import std.array : appender;

        auto points = appender!(Vector2d[]);
        linePoints(startXPos, startYPos, endXPos, endYPos, (p) {
            points ~= p;
            return true;
        });
        return points[];
    }

    void linePoints(Vector2d start, Vector2d end, scope bool delegate(
            Vector2d) onPoint)
    {
        linePoints(start.x, start.y, end.x, end.y, onPoint);
    }

    void linePoints(double startXPos, double startYPos, double endXPos, double endYPos, scope bool delegate(
            Vector2d) onPoint)
    {
        //Bresenham algorithm
        import math = deltotum.math;

        int startX = toInt(startXPos);
        int startY = toInt(startYPos);
        int endX = toInt(endXPos);
        int endY = toInt(endYPos);

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
            if (!onPoint(Vector2d(startX, startY)))
            {
                return;
            }
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
    }

    Vector2d[] circlePoints(Vector2d pos, int radius)
    {
        return circlePoints(pos.x, pos.y, radius);
    }

    Vector2d[] circlePoints(double centerXPos, double centerYPos, int radius)
    {
        import std.array : appender;

        auto points = appender!(Vector2d[]);
        circlePoints(centerXPos, centerYPos, radius, (p) {
            points ~= p;
            return true;
        });
        return points[];
    }

    void circlePoints(Vector2d pos, int radius, scope bool delegate(Vector2d) onPoint)
    {
        circlePoints(pos.x, pos.y, radius, onPoint);
    }

    void circlePoints(double centerXPos, double centerYPos, int radius, scope bool delegate(
            Vector2d) onPoint)
    {
        ellipse(centerXPos, centerYPos, radius, radius, (p1, p2) {
            if (!onPoint(p1))
            {
                return false;
            }
            if (!onPoint(p2))
            {
                return false;
            }
            return true;
        }, (p1, p2) {
            if (!onPoint(p1))
            {
                return false;
            }
            if (!onPoint(p2))
            {
                return false;
            }
            return true;
        });
    }

    void circle(double centerX, double centerY, double radius, RGBA color = defaultColor, bool isFill = false)
    {
        ellipse(Vector2d(centerX, centerY), Vector2d(radius, radius), color, true, true);
    }

    void circle(double centerX, double centerY, double radius)
    {
        int radiusInt = toInt(radius);
        ellipse(centerX, centerY, radiusInt, radiusInt);
    }

    void ellipse(Vector2d centerPos, Vector2d radiusXY, RGBA color, bool isFillTop = false, bool isFillBottom = false)
    {
        changeColor(color);
        scope (exit)
        {
            restoreColor;
        }
        ellipse(centerPos, radiusXY,
            (p1, p2) {
            point(p1);
            point(p2);
            if (isFillTop)
            {
                line(p1, p2);
            }
            return true;
        },
            (p1, p2) {
            point(p1);
            point(p2);
            if (isFillBottom)
            {
                line(p1, p2);
            }
            return true;
        });
    }

    void ellipse(Vector2d centerPos, Vector2d radiusXY)
    {
        ellipse(centerPos.x, centerPos.y, toInt(radiusXY.x), toInt(radiusXY.y));
    }

    void ellipse(double centerX, double centerY, int radiusX, int radiusY)
    {
        ellipse(centerX, centerY, radiusX, radiusY,
            (p1, p2) { point(p1); point(p2); return true; },
            (p1, p2) { point(p1); point(p2); return true; });
    }

    void ellipse(Vector2d centerPos, Vector2d radiusXY,
        scope bool delegate(Vector2d, Vector2d) onTopQuadPoints,
        scope bool delegate(Vector2d, Vector2d) onBottomQuadPoints)
    {
        ellipse(centerPos.x, centerPos.y, toInt(radiusXY.x), toInt(radiusXY.y), onTopQuadPoints, onBottomQuadPoints);
    }

    void ellipse(double centerXPos, double centerYPos, int radiusX, int radiusY,
        scope bool delegate(Vector2d, Vector2d) onTopQuadPoints,
        scope bool delegate(Vector2d, Vector2d) onBottomQuadPoints)
    {
        //John Kennedy fast Bresenham algorithm
        int centerX = toInt(centerXPos);
        int centerY = toInt(centerYPos);

        auto drawPoints = (int x, int y) {
            auto quadrand1Point = Vector2d(centerX + x, centerY + y);
            auto quadrand2Point = Vector2d(centerX - x, centerY + y);

            if (!onBottomQuadPoints(quadrand1Point, quadrand2Point))
            {
                return false;
            }

            auto quadrand3Point = Vector2d(centerX - x, centerY - y);
            auto quadrand4Point = Vector2d(centerX + x, centerY - y);

            if (!onTopQuadPoints(quadrand3Point, quadrand4Point))
            {
                return false;
            }
            return true;
        };

        int twoASquare = 2 * radiusX * radiusX;
        int twoBSquare = 2 * radiusY * radiusY;
        int x = radiusX;
        int y;
        int changeX = radiusY * radiusY * (1 - 2 * radiusX);
        int changeY = radiusX * radiusX;
        int ellipseError;
        int stoppingX = twoBSquare * radiusX;
        int stoppingY;

        while (stoppingX >= stoppingY)
        {
            if (!drawPoints(x, y))
            {
                return;
            }
            y++;
            stoppingY += twoASquare;
            ellipseError += changeY;
            changeY += twoASquare;
            if ((2 * ellipseError + changeX) > 0)
            {
                x--;
                stoppingX -= twoBSquare;
                ellipseError += changeX;
                changeX += twoBSquare;
            }

        }

        x = 0;
        y = radiusY;
        changeX = radiusY * radiusY;
        changeY = radiusX * radiusX * (1 - 2 * radiusY);
        ellipseError = 0;
        stoppingX = 0;
        stoppingY = twoASquare * radiusY;
        while (stoppingX <= stoppingY)
        {
            if (!drawPoints(x, y))
            {
                return;
            }
            x++;
            stoppingX += twoBSquare;
            ellipseError += changeX;
            changeX += twoBSquare;
            if ((2 * ellipseError + changeY) > 0)
            {
                y--;
                stoppingY -= twoASquare;
                ellipseError += changeY;
                changeY += twoASquare;
            }
        }
    }

    void fillTriangle(Vector2d v1, Vector2d v2, Vector2d v3, RGBA fillColor)
    {
        scope Vector2d[] side1LinePoints = linePoints(v1.x, v1.y, v2.x, v2.y);
        scope Vector2d[] side2LinePoints = linePoints(v3.x, v3.y, v2.x, v2.y);
        fillPolyLines(side1LinePoints, side2LinePoints, fillColor);
    }

    void fillRect(Vector2d pos, double width, double height, RGBA fillColor = defaultColor)
    {
        fillRect(pos.x, pos.y, width, height, fillColor);
    }

    void fillRect(double x, double y, double width, double height, RGBA fillColor = defaultColor)
    {
        changeColor(fillColor);
        scope (exit)
        {
            restoreColor;
        }
        if (const err = renderer.fillRect(toInt(x), toInt(y), toInt(width), toInt(height)))
        {
            logger.errorf("Fill rect error. %s", err);
        }
    }

    void rect(Vector2d pos, double width, double height, RGBA color = defaultColor)
    {
        rect(pos.x, pos.y, width, height, color);
    }

    void rect(double x, double y, double width, double height, RGBA color = defaultColor)
    {
        changeColor(color);
        scope (exit)
        {
            restoreColor;
        }
        rect(x, y, width, height);
    }

    void rect(Vector2d pos, double width, double height)
    {
        rect(pos.x, pos.y, width, height);
    }

    void rect(double x, double y, double width, double height)
    {
        if (const err = renderer.rect(toInt(x), toInt(y), toInt(width), toInt(height)))
        {
            logger.errorf("Draw rect error. %s", err);
        }
    }

    void rect(Vector2d pos, double width, double height, GraphicStyle style = GraphicStyle.simple)
    {
        rect(pos.x, pos.y, width, height, style);
    }

    void rect(double x, double y, double width, double height, GraphicStyle style = GraphicStyle
            .simple)
    {
        if (style.isFill && style.lineWidth == 0)
        {
            rect(x, y, width, height, style.fillColor);
            return;
        }

        rect(x, y, width, height, style.lineColor);

        const lineWidth = style.lineWidth;
        rect(x + lineWidth, y + lineWidth, width - lineWidth * 2, height - lineWidth * 2, style
                .fillColor);
    }

    void bezier(Vector2d p0, RGBA color, scope Vector2d delegate(double v) onInterpValue, bool delegate(
            Vector2d) onPoint = null)
    {
        changeColor(color);
        scope (exit)
        {
            restoreColor;
        }
        bezier(p0, onInterpValue, onPoint);
    }

    void bezier(Vector2d p0,
        scope Vector2d delegate(double v) onInterpValue,
        bool delegate(Vector2d) onPoint = null,
        double delta = 0.01)
    {
        //enum delta = 0.01; //100 segments
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
            line(toInt(start.x), toInt(start.y), toInt(end.x), toInt(end.y));
            start = end;
        }
    }

    void bezier(Vector2d p0, Vector2d p1, Vector2d p2, scope bool delegate(
            Vector2d) onPoint = null)
    {
        bezier(p0, (t) { return bezierInterp(p0, p1, p2, t); }, onPoint);
    }

    void bezier(Vector2d p0, Vector2d p1, Vector2d p2, Vector2d p3, scope bool delegate(
            Vector2d) onPoint = null)
    {
        bezier(p0, (t) { return bezierInterp(p0, p1, p2, p3, t); }, onPoint);
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
        changeColor(fillColor);
        scope (exit)
        {
            restoreColor;
        }
        return fillPolyLines(vertexStart, vertexEnd);
    }

    bool fillPolyLines(Vector2d[] vertexStart, Vector2d[] vertexEnd)
    {
        foreach (i, vStart; vertexStart)
        {
            if (i >= vertexEnd.length)
            {
                break;
            }
            const vEnd = vertexEnd[i];
            line(vStart, vEnd);
        }
        return true;
    }

    void draw(scope void delegate() onDraw)
    {
        import deltotum.kit.graphics.colors.rgba : RGBA;

        //isClearingInCycle
        const screenColor = RGBA.black;
        if (const err = renderer.setRenderDrawColor(screenColor.r, screenColor.g, screenColor.b, screenColor
                .aNorm))
        {
            //TODO logging in main loop?
        }
        else
        {
            if (const err = renderer.clear)
            {
                //TODO logging in main loop?
            }
        }

        onDraw();

        renderer.present;
    }

    double scaleFactorFor(long width, long height)
    {
        int outputWidth;
        int outputHeight;

        if (const err = renderer.getOutputSize(&outputWidth, &outputHeight))
        {
            logger.error("Error getting renderer size: ", err.toString);
            return 0;
        }

        long windowWidth = width;
        long windowHeight = height;

        //TODO height
        double scale = (cast(double)(outputWidth)) / windowWidth;
        return scale;
    }
}
