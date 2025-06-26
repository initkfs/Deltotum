module api.dm.kit.graphics.graphic;

import api.dm.com.com_result : ComResult;

import api.core.components.units.services.loggable_unit;
import api.core.utils.factories : ProviderFactory;

import api.dm.com.graphic.com_renderer : ComRenderer;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2d, Vec2i, Vec2f;
import math = api.dm.math;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

import Math = api.dm.math;

import api.math.pos2.flip : Flip;
import api.math.geom2.rect2 : Rect2d, Rect2f;
import api.math.geom2.line2 : Line2d;

import api.core.loggers.logging : Logging;
import std.conv : to;

import api.dm.com.graphic.com_texture : ComTexture;
import api.dm.com.graphic.com_surface : ComSurface;
import api.dm.com.graphic.com_image : ComImage;
import api.dm.com.graphic.com_blend_mode : ComBlendMode;

/**
 * Authors: initkfs
 */
class Graphic : LoggableUnit
{
    //TODO remove
    static RGBA defaultColor = RGBA.red;

    RGBA screenColor = RGBA.black;

    protected
    {
        ComBlendMode prevMode;
        bool isBlendModeByColorChanged;
        RGBA prevColor;
        ComRenderer renderer;
    }

    ProviderFactory!ComTexture comTextureProvider;
    ProviderFactory!ComSurface comSurfaceProvider;
    ProviderFactory!ComImage comImageProvider;

    this(Logging logging, ComRenderer renderer)
    {
        super(logging);

        import std.exception : enforce;

        //TODO opengl
        // enforce(renderer !is null, "Renderer must not be null");
        this.renderer = renderer;
    }

    pragma(inline, true)
    private int toInt(double value) pure @safe const nothrow
    {
        return cast(int) value;
    }

    pragma(inline, true)
    private float toFloat(double value) pure @safe const nothrow
    {
        return cast(float) value;
    }

    Rect2d clip()
    {
        Rect2d clip;
        if (const err = renderer.getClipRect(clip))
        {
            import std.conv : text;

            throw new Exception(text("Error receiving clipping. ", err));
        }
        return clip;
    }

    void clip(Rect2d clipRect)
    {
        if (const err = renderer.setClipRect(clipRect))
        {
            import std.conv : text;

            throw new Exception(text("Error setting clipping. ", err));
        }
    }

    void clearClip()
    {
        if (const err = renderer.removeClipRect)
        {
            import std.conv : text;

            throw new Exception(text("Error removing clipping. ", err));
        }
    }

    ComResult readPixels(Rect2d bounds, ComSurface pixelBuffer) => renderer.readPixels(bounds, pixelBuffer);

    RGBA color()
    {
        ubyte r, g, b, a;
        if (const err = renderer.getDrawColor(r, g, b, a))
        {
            logger.error("Error getting current renderer color: ", err);
            return RGBA.init;
        }
        return RGBA(r, g, b, (cast(double) a) / RGBA.maxColor);
    }

    RGBA color(RGBA newColor)
    {
        prevColor = newColor;

        changeColor(newColor);

        if (newColor.a != RGBA.maxAlpha)
        {
            changeBlendMode(ComBlendMode.blend);
            isBlendModeByColorChanged = true;
        }

        return prevColor;
    }

    void changeColor(RGBA color)
    {
        if (const err = renderer.setDrawColor(color.r, color.g, color.b, color.aByte))
        {
            logger.error("Error setting render color: ", err);
        }
    }

    void restoreColor()
    {
        if (isBlendModeByColorChanged)
        {
            restoreBlendMode;
            isBlendModeByColorChanged = false;
        }
        changeColor(prevColor);
    }

    ComBlendMode changeBlendMode(ComBlendMode mode = ComBlendMode.blend)
    {
        ComBlendMode mustBePrevMode;
        if (const err = renderer.getBlendMode(mustBePrevMode))
        {
            logger.error("Error getting renderer blengind mode: ", err);
            return ComBlendMode.none;
        }

        if (mode == mustBePrevMode)
        {
            return mustBePrevMode;
        }

        prevMode = mustBePrevMode;

        blendMode(mode);

        return prevMode;
    }

    void blendMode(ComBlendMode mode = ComBlendMode.blend)
    {
        if (const err = renderer.setBlendMode(mode))
        {
            logger.error("Error setting blending mode for the renderer: ", err);
        }
    }

    void restoreBlendMode()
    {
        blendMode(prevMode);
    }

    void line(double startX, double startY, double endX, double endY)
    {
        if (const err = renderer.drawLine(toFloat(startX), toFloat(startY), toFloat(endX), toFloat(
                endY)))
        {
            logger.error("Line drawing error. ", err);
        }
    }

    void line(Vec2d start, Vec2d end)
    {
        line(start.x, start.y, end.x, end.y);
    }

    void line(Vec2d start, Vec2d end, RGBA color = defaultColor)
    {
        line(start.x, start.y, end.x, end.y, color);
    }

    void line(Line2d ln)
    {
        line(ln.start, ln.end);
    }

    void line(Line2d ln, RGBA color = defaultColor)
    {
        line(ln.start, ln.end, color);
    }

    void line(double startX, double startY, double endX, double endY, RGBA color = defaultColor)
    {
        this.color(color);
        scope (exit)
        {
            restoreColor;
        }
        line(startX, startY, endX, endY);
    }

    void polygon(Vec2d[] points)
    {
        if (points.length == 0)
        {
            return;
        }

        if (const err = renderer.drawLines(points))
        {
            logger.error("Lines drawing error: ", err);
        }

        if (points.length >= 3)
        {
            const last = points[$ - 1];
            const first = points[0];
            line(last.x, last.y, first.x, first.y);
        }
    }

    void polygon(Vec2d[] points, RGBA color = defaultColor) => polygon(points, points.length, color);

    void polygon(Vec2d[] points, size_t count, RGBA color = defaultColor)
    {
        if (points.length == 0)
        {
            return;
        }
        this.color(color);
        scope (exit)
        {
            restoreColor;
        }

        polygon(points, count);
    }

    void point(double x, double y)
    {
        if (const err = renderer.drawPoint(toFloat(x), toFloat(y)))
        {
            logger.error("Point drawing error: ", err);
        }
    }

    void point(Vec2d p)
    {
        point(p.x, p.y);
    }

    void point(double x, double y, RGBA color = defaultColor)
    {
        this.color(color);
        scope (exit)
        {
            restoreColor;
        }

        point(x, y);
    }

    void point(Vec2d p, RGBA color = defaultColor)
    {
        point(p.x, p.y, color);
    }

    void points(Vec2d[] points)
    {
        if (points.length == 0)
        {
            return;
        }
        if (const err = renderer.drawPoints(points))
        {
            logger.error("Double points drawing error: ", err);
        }
    }

    void points(Vec2d[] p, RGBA color = defaultColor)
    {
        if (p.length == 0)
        {
            return;
        }
        this.color(color);
        scope (exit)
        {
            restoreColor;
        }

        points(p);
    }

    void points(Vec2f[] p, RGBA color = defaultColor)
    {
        if (p.length == 0)
        {
            return;
        }
        this.color(color);
        scope (exit)
        {
            restoreColor;
        }

        if (const err = renderer.drawPoints(p))
        {
            logger.error("Float points drawing error: ", err);
        }
    }

    Vec2d[] linePoints(Vec2d start, Vec2d end)
    {
        return linePoints(start.x, start.y, end.x, end.y);
    }

    Vec2d[] linePoints(double startXPos, double startYPos, double endXPos, double endYPos)
    {
        import std.array : appender;

        auto points = appender!(Vec2d[]);
        linePoints(startXPos, startYPos, endXPos, endYPos, (p) {
            points ~= p;
            return true;
        });
        return points[];
    }

    void linePoints(Vec2d start, Vec2d end, scope bool delegate(
            Vec2d) onPoint)
    {
        linePoints(start.x, start.y, end.x, end.y, onPoint);
    }

    void linePoints(double startXPos, double startYPos, double endXPos, double endYPos, scope bool delegate(
            Vec2d) onPoint)
    {
        //Bresenham algorithm
        import math = api.dm.math;

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
            if (!onPoint(Vec2d(startX, startY)))
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

    Vec2d[] circlePoints(Vec2d pos, int radius)
    {
        return circlePoints(pos.x, pos.y, radius);
    }

    Vec2d[] circlePoints(double centerXPos, double centerYPos, int radius)
    {
        import std.array : appender;

        auto points = appender!(Vec2d[]);
        circlePoints(centerXPos, centerYPos, radius, (p) {
            points ~= p;
            return true;
        });
        return points[];
    }

    void circlePoints(Vec2d pos, int radius, scope bool delegate(Vec2d) onPoint)
    {
        circlePoints(pos.x, pos.y, radius, onPoint);
    }

    void circlePoints(double centerXPos, double centerYPos, int radius, scope bool delegate(
            Vec2d) onPoint)
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

    //TODO Determine the position 0 on the trigonometric circle and the clockwise/counterclockwise movements
    void arc(double xCenter, double yCenter, double startAngleDeg, double endAngleDeg, double radiusArc)
    {
        assert(startAngleDeg != endAngleDeg);
        assert(startAngleDeg < endAngleDeg);

        immutable int radius = toInt(radiusArc);
        immutable int centerX = toInt(xCenter);
        immutable int centerY = toInt(yCenter);

        immutable angleRadIncr = 1.0 / radius;

        double startAngle = Math.degToRad(startAngleDeg);
        double endAngle = Math.degToRad(endAngleDeg);

        double angleRad = startAngle;
        while (angleRad <= endAngle)
        {
            immutable double x = radius * Math.cos(angleRad);
            immutable double y = radius * Math.sin(angleRad);
            point(centerX + x, centerY + y);
            angleRad += angleRadIncr;
        }
    }

    void fillCircle(Vec2d center, double radius)
    {
        circle(center.x, center.y, radius, true);
    }

    void fillCircle(double centerX, double centerY, double radius)
    {
        circle(centerX, centerY, radius, true);
    }

    void fillCircle(double centerX, double centerY, double radius, RGBA color = defaultColor)
    {
        circle(centerX, centerY, radius, color, true);
    }

    void circle(double centerX, double centerY, double radius, bool isFill = false)
    {
        ellipse(Vec2d(centerX, centerY), Vec2d(radius, radius), isFill, isFill);
    }

    void circle(double centerX, double centerY, double radius, RGBA color = defaultColor, bool isFill = false)
    {
        ellipse(Vec2d(centerX, centerY), Vec2d(radius, radius), color, isFill, isFill);
    }

    void circle(double centerX, double centerY, double radius)
    {
        int radiusInt = toInt(radius);
        ellipse(centerX, centerY, radiusInt, radiusInt);
    }

    void ellipse(Vec2d centerPos, Vec2d radiusXY, RGBA color, bool isFillTop = false, bool isFillBottom = false)
    {
        this.color(color);
        scope (exit)
        {
            restoreColor;
        }
        ellipse(centerPos, radiusXY, isFillTop, isFillBottom);
    }

    void ellipse(Vec2d centerPos, Vec2d radiusXY, bool isFillTop = false, bool isFillBottom = false)
    {
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

    void ellipse(Vec2d centerPos, Vec2d radiusXY)
    {
        ellipse(centerPos.x, centerPos.y, toInt(radiusXY.x), toInt(radiusXY.y));
    }

    void ellipse(double centerX, double centerY, int radiusX, int radiusY)
    {
        ellipse(centerX, centerY, radiusX, radiusY,
            (p1, p2) { point(p1); point(p2); return true; },
            (p1, p2) { point(p1); point(p2); return true; });
    }

    void ellipse(Vec2d centerPos, Vec2d radiusXY,
        scope bool delegate(Vec2d, Vec2d) onTopQuadPoints,
        scope bool delegate(Vec2d, Vec2d) onBottomQuadPoints)
    {
        ellipse(centerPos.x, centerPos.y, toInt(radiusXY.x), toInt(radiusXY.y), onTopQuadPoints, onBottomQuadPoints);
    }

    void ellipse(double centerXPos, double centerYPos, int radiusX, int radiusY,
        scope bool delegate(Vec2d, Vec2d) onTopQuadPoints,
        scope bool delegate(Vec2d, Vec2d) onBottomQuadPoints)
    {
        //John Kennedy fast Bresenham algorithm
        int centerX = toInt(centerXPos);
        int centerY = toInt(centerYPos);

        auto drawPoints = (int x, int y) {
            auto quadrand1Point = Vec2d(centerX + x, centerY + y);
            auto quadrand2Point = Vec2d(centerX - x, centerY + y);

            if (!onBottomQuadPoints(quadrand1Point, quadrand2Point))
            {
                return false;
            }

            auto quadrand3Point = Vec2d(centerX - x, centerY - y);
            auto quadrand4Point = Vec2d(centerX + x, centerY - y);

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

    void fillTriangle(Vec2d v01, Vec2d v02, Vec2d v03, RGBA fillColor)
    {
        color(fillColor);
        scope (exit)
        {
            restoreColor;
        }

        fillTriangle(v01, v02, v03);
    }

    void fillTriangle(Vec2d v01, Vec2d v02, Vec2d v03)
    {
        void scanline(const ref Vec2d v1, const ref Vec2d v2, const ref Vec2d v3, bool isFlatBottom = true)
        {
            double lineGradient1 = 0;
            double lineGradient2 = 0;
            double x1 = 0;
            double x2 = 0;
            if (isFlatBottom)
            {
                lineGradient1 = (v2.x - v1.x) / (v2.y - v1.y);
                lineGradient2 = (v3.x - v1.x) / (v3.y - v1.y);

                x1 = v1.x;
                x2 = v1.x + 0.5;

                for (auto scanlineY = toInt(v1.y); scanlineY <= v2.y; scanlineY++)
                {
                    line(toInt(x1), scanlineY, toInt(x2), scanlineY);
                    x1 += lineGradient1;
                    x2 += lineGradient2;
                }
            }
            else
            {
                lineGradient1 = (v3.x - v1.x) / (v3.y - v1.y);
                lineGradient2 = (v3.x - v2.x) / (v3.y - v2.y);

                x1 = v3.x;
                x2 = v3.x + 0.5;

                for (auto scanlineY = toInt(v3.y); scanlineY > v1.y; scanlineY--)
                {
                    line(toInt(x1), scanlineY, toInt(x2), scanlineY);
                    x1 -= lineGradient1;
                    x2 -= lineGradient2;
                }
            }
        }

        import std.algorithm.sorting : sort;

        Vec2d[3] vertexByY = [v01, v02, v03];
        vertexByY[].sort!((v1, v2) => v1.y < v2.y);

        Vec2d vt1 = vertexByY[0];
        Vec2d vt2 = vertexByY[1];
        Vec2d vt3 = vertexByY[2];

        if (vt2.y == vt3.y)
        {
            //flat bottom
            scanline(vt1, vt2, vt3);
        }
        else if (vt1.y == vt2.y)
        {
            //flat top
            scanline(vt1, vt2, vt3, false);
        }
        else
        {
            const tempX = vt1.x + ((vt2.y - vt1.y) / (vt3.y - vt1.y)) * (vt3.x - vt1.x);
            const tempY = vt2.y;
            Vec2d temp = Vec2d(tempX, tempY);
            scanline(vt1, vt2, temp);
            scanline(vt2, temp, vt3, false);
        }
    }

    void fillRect(Rect2d bounds)
    {
        fillRect(bounds.x, bounds.y, bounds.width, bounds.height);
    }

    void fillRect(Vec2d pos, double width, double height, RGBA fillColor = defaultColor)
    {
        fillRect(pos.x, pos.y, width, height, fillColor);
    }

    void fillRect(double x, double y, double width, double height, RGBA fillColor = defaultColor)
    {
        color(fillColor);
        scope (exit)
        {
            restoreColor;
        }
        fillRect(x, y, width, height);
    }

    void fillRect(double x, double y, double width, double height)
    {
        if (const err = renderer.drawFillRect(toFloat(x), toFloat(y), toFloat(width), toFloat(
                height)))
        {
            logger.error("Fill rect error: ", err);
        }
    }

    void fillRects(Rect2d[] rects, RGBA fillColor = defaultColor)
    {
        color(fillColor);
        scope (exit)
        {
            restoreColor;
        }
        if (const err = renderer.drawFillRects(rects))
        {
            logger.error("Fill rects error: ", err);
        }
    }

    void rect(Vec2d pos, double width, double height, RGBA color = defaultColor)
    {
        rect(pos.x, pos.y, width, height, color);
    }

    void rect(double x, double y, double width, double height, RGBA color = defaultColor)
    {
        this.color(color);
        scope (exit)
        {
            restoreColor;
        }
        rect(x, y, width, height);
    }

    void rect(Rect2d bounds)
    {
        rect(bounds.x, bounds.y, bounds.width, bounds.height);
    }

    void rect(Vec2d pos, double width, double height)
    {
        rect(pos.x, pos.y, width, height);
    }

    void rect(double x, double y, double width, double height)
    {
        if (const err = renderer.drawRect(toFloat(x), toFloat(y), toFloat(width), toFloat(height)))
        {
            logger.error("Draw rect error: ", err);
        }
    }

    void rect(Vec2d pos, double width, double height, GraphicStyle style = GraphicStyle.simple)
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

    void bezier(Vec2d p0, RGBA color, scope Vec2d delegate(double v) onInterpValue, bool delegate(
            Vec2d) onPoint = null)
    {
        this.color(color);
        scope (exit)
        {
            restoreColor;
        }
        bezier(p0, onInterpValue, onPoint);
    }

    void bezier(Vec2d p0,
        scope Vec2d delegate(double v) onInterpValue,
        bool delegate(Vec2d) onPoint = null,
        double delta = 0.01)
    {
        //enum delta = 0.01; //100 segments
        Vec2d start = p0;
        //TODO exact comparison of doubles?
        for (double i = 0; i < 1; i += delta)
        {
            auto end = onInterpValue(i);
            if (onPoint !is null && !onPoint(end))
            {
                start = end;
                continue;
            }
            line(toFloat(start.x), toFloat(start.y), toFloat(end.x), toFloat(end.y));
            start = end;
        }
    }

    void bezier(Vec2d p0, Vec2d p1, Vec2d p2, scope bool delegate(
            Vec2d) onPoint = null)
    {
        bezier(p0, (t) { return bezierInterp(p0, p1, p2, t); }, onPoint);
    }

    void bezier(Vec2d p0, Vec2d p1, Vec2d p2, Vec2d p3, scope bool delegate(
            Vec2d) onPoint = null)
    {
        bezier(p0, (t) { return bezierInterp(p0, p1, p2, p3, t); }, onPoint);
    }

    private Vec2d bezierInterp(Vec2d p0, Vec2d p1, Vec2d p2, Vec2d p3, double t) nothrow pure @safe
    {
        const dt = 1 - t;
        Vec2d p0p1 = p0.scale(dt).add(p1.scale(t));
        Vec2d p1p2 = p1.scale(dt).add(p2.scale(t));
        Vec2d p2p3 = p2.scale(dt).add(p3.scale(t));
        Vec2d p0p1p2 = p0p1.scale(dt).add(p1p2.scale(t));
        Vec2d p1p2p3 = p1p2.scale(dt).add(p2p3.scale(t));
        Vec2d result = p0p1p2.scale(dt).add(p1p2p3.scale(t));

        return result;
    }

    private Vec2d bezierInterp(Vec2d p0, Vec2d p1, Vec2d p2, double t) nothrow pure @safe
    {
        const dt = 1 - t;
        Vec2d p0p1 = p0.scale(dt).add(p1.scale(t));
        Vec2d p1p2 = p1.scale(dt).add(p2.scale(t));
        Vec2d result = p0p1.scale(dt).add(p1p2.scale(t));
        return result;
    }

    bool fillPolyLines(Vec2d[] vertexStart, Vec2d[] vertexEnd, RGBA fillColor)
    {
        color(fillColor);
        scope (exit)
        {
            restoreColor;
        }
        return fillPolyLines(vertexStart, vertexEnd);
    }

    bool fillPolyLines(Vec2d[] vertexStart, Vec2d[] vertexEnd)
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

    void rendererPresent()
    {
        if (const err = renderer.present)
        {
            logger.error(err.toString);
        }
    }

    void clear()
    {
        clear(screenColor);
    }

    void clearTransparent()
    {
        clear(RGBA.transparent);
    }

    void clear(RGBA color)
    {
        this.color(color);
        scope (exit)
        {
            restoreColor;
        }

        if (const err = renderer.clearAndFill)
        {
            //TODO logging in main loop?
        }
    }

    Rect2d viewport()
    {
        Rect2d v;
        if (const err = renderer.getViewport(v))
        {
            logger.error("Error getting renderer viewport: ", err);
        }
        return v;
    }

    void viewport(Rect2d v)
    {
        if (const err = renderer.setViewport(v))
        {
            logger.error("Error setting renderer viewport: ", err);
        }
    }

    void scale(double scaleX, double scaleY)
    {
        if (const err = renderer.setScale(scaleX, scaleY))
        {
            logger.error(err);
        }
    }

    // void logicalSize(int width, int height)
    // {
    //     if (const err = renderer.setLogicalSize(width, height))
    //     {
    //         logger.error(err);
    //     }
    // }

    Rect2d renderBounds()
    {
        int outputWidth;
        int outputHeight;

        if (const err = renderer.getOutputSize(outputWidth, outputHeight))
        {
            logger.error("Error getting renderer output size: ", err);
            return Rect2d.init;
        }

        return Rect2d(0, 0, outputWidth, outputHeight);
    }
}
