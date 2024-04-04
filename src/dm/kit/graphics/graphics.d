module dm.kit.graphics.graphics;

import dm.core.components.units.services.loggable_unit;
import dm.core.utils.provider : Provider;

import dm.com.graphics.com_renderer : ComRenderer;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.math.vector2 : Vector2;
import math = dm.math;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.kit.graphics.themes.theme : Theme;
import dm.kit.sprites.textures.texture : Texture;

import Math = dm.math;

import dm.math.flip : Flip;
import dm.math.rect2d : Rect2d;

import std.logger.core : Logger;
import std.conv : to;

import dm.com.graphics.com_texture : ComTexture;
import dm.com.graphics.com_surface : ComSurface;
import dm.com.graphics.com_image : ComImage;
import dm.com.graphics.com_blend_mode : ComBlendMode;

/**
 * Authors: initkfs
 */
class Graphics : LoggableUnit
{
    //TODO move to gui module
    Theme theme;

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

    Provider!ComTexture comTextureProvider;
    Provider!ComSurface comSurfaceProvider;
    Provider!ComImage comImageProvider;

    this(Logger logger, ComRenderer renderer, Theme theme)
    {
        super(logger);

        import std.exception : enforce;

        //TODO opengl
        // enforce(renderer !is null, "Renderer must not be null");
        this.renderer = renderer;

        enforce(theme !is null, "Theme must not be null");
        this.theme = theme;
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

    void readPixels(Rect2d bounds, ComSurface surface)
    {
        uint format;
        if (const err = surface.getFormat(format))
        {
            logger.error(err.toString);
        }
        int pitch;
        if (const err = surface.getPitch(pitch))
        {
            logger.error(err.toString);
        }
        void* pixels;
        if (const err = surface.getPixels(pixels))
        {
            logger.error(err.toString);
        }
        readPixels(bounds, format, pitch, pixels);
    }

    void readPixels(Rect2d bounds, uint format, int pitch, void* pixelBuffer)
    {
        if (const err = renderer.readPixels(bounds, format, pitch, pixelBuffer))
        {
            throw new Exception(err.toString);
        }
    }

    RGBA changeColor(RGBA color = defaultColor)
    {
        ubyte r, g, b, a;
        if (const err = renderer.getDrawColor(r, g, b, a))
        {
            logger.errorf("Error getting current renderer color");
            return prevColor;
        }

        const aByte = (cast(double) a) / ubyte.max;
        prevColor = RGBA(r, g, b, aByte);

        setColor(color);

        if (color.a != RGBA.maxAlpha)
        {
            changeBlendMode(ComBlendMode.blend);
            isBlendModeByColorChanged = true;
        }

        return prevColor;
    }

    void setColor(RGBA color)
    {
        if (const err = renderer.setDrawColor(color.r, color.g, color.b, color.aByte))
        {
            logger.errorf("Adjust render error. %s", err);
        }
    }

    void restoreColor()
    {
        if (isBlendModeByColorChanged)
        {
            restoreBlendMode;
            isBlendModeByColorChanged = false;
        }
        setColor(prevColor);
    }

    ComBlendMode changeBlendMode(ComBlendMode mode = ComBlendMode.blend)
    {
        ComBlendMode mustBePrevMode;
        if (const err = renderer.getBlendMode(mustBePrevMode))
        {
            logger.errorf("Error getting renderer blengind mode");
            return ComBlendMode.none;
        }

        //TODO check prev == mode
        prevMode = mustBePrevMode;

        setBlendMode(mode);

        return prevMode;
    }

    void setBlendMode(ComBlendMode mode = ComBlendMode.blend)
    {
        if (const err = renderer.setBlendMode(mode))
        {
            logger.error("Error setting blending mode for the renderer. ", err);
        }
    }

    void restoreBlendMode()
    {
        setBlendMode(prevMode);
    }

    void line(double startX, double startY, double endX, double endY)
    {
        if (const err = renderer.drawLine(toInt(startX), toInt(startY), toInt(endX), toInt(endY)))
        {
            logger.error("Line drawing error. ", err);
        }
    }

    void line(Vector2 start, Vector2 end)
    {
        line(start.x, start.y, end.x, end.y);
    }

    void line(Vector2 start, Vector2 end, RGBA color = defaultColor)
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

    void lines(Vector2[] points)
    {
        if (const err = renderer.drawLines(points))
        {
            logger.errorf("Lines drawing error. %s", err);
        }
    }

    void lines(Vector2[] points, RGBA color = defaultColor)
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
        if (const err = renderer.drawPoint(toInt(x), toInt(y)))
        {
            logger.errorf("Point drawing error. %s", err);
        }
    }

    void point(Vector2 p)
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

    void point(Vector2 p, RGBA color = defaultColor)
    {
        point(p.x, p.y, color);
    }

    void points(Vector2[] points)
    {
        foreach (p; points)
        {
            point(p.x, p.y);
        }
    }

    void points(Vector2[] p, RGBA color = defaultColor)
    {
        changeColor(color);
        scope (exit)
        {
            restoreColor;
        }

        points(p);
    }

    Vector2[] linePoints(Vector2 start, Vector2 end)
    {
        return linePoints(start.x, start.y, end.x, end.y);
    }

    Vector2[] linePoints(double startXPos, double startYPos, double endXPos, double endYPos)
    {
        import std.array : appender;

        auto points = appender!(Vector2[]);
        linePoints(startXPos, startYPos, endXPos, endYPos, (p) {
            points ~= p;
            return true;
        });
        return points[];
    }

    void linePoints(Vector2 start, Vector2 end, scope bool delegate(
            Vector2) onPoint)
    {
        linePoints(start.x, start.y, end.x, end.y, onPoint);
    }

    void linePoints(double startXPos, double startYPos, double endXPos, double endYPos, scope bool delegate(
            Vector2) onPoint)
    {
        //Bresenham algorithm
        import math = dm.math;

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
            if (!onPoint(Vector2(startX, startY)))
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

    Vector2[] circlePoints(Vector2 pos, int radius)
    {
        return circlePoints(pos.x, pos.y, radius);
    }

    Vector2[] circlePoints(double centerXPos, double centerYPos, int radius)
    {
        import std.array : appender;

        auto points = appender!(Vector2[]);
        circlePoints(centerXPos, centerYPos, radius, (p) {
            points ~= p;
            return true;
        });
        return points[];
    }

    void circlePoints(Vector2 pos, int radius, scope bool delegate(Vector2) onPoint)
    {
        circlePoints(pos.x, pos.y, radius, onPoint);
    }

    void circlePoints(double centerXPos, double centerYPos, int radius, scope bool delegate(
            Vector2) onPoint)
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

    void circle(double centerX, double centerY, double radius, RGBA color = defaultColor, bool isFill = false)
    {
        ellipse(Vector2(centerX, centerY), Vector2(radius, radius), color, isFill, isFill);
    }

    void circle(double centerX, double centerY, double radius)
    {
        int radiusInt = toInt(radius);
        ellipse(centerX, centerY, radiusInt, radiusInt);
    }

    void ellipse(Vector2 centerPos, Vector2 radiusXY, RGBA color, bool isFillTop = false, bool isFillBottom = false)
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

    void ellipse(Vector2 centerPos, Vector2 radiusXY)
    {
        ellipse(centerPos.x, centerPos.y, toInt(radiusXY.x), toInt(radiusXY.y));
    }

    void ellipse(double centerX, double centerY, int radiusX, int radiusY)
    {
        ellipse(centerX, centerY, radiusX, radiusY,
            (p1, p2) { point(p1); point(p2); return true; },
            (p1, p2) { point(p1); point(p2); return true; });
    }

    void ellipse(Vector2 centerPos, Vector2 radiusXY,
        scope bool delegate(Vector2, Vector2) onTopQuadPoints,
        scope bool delegate(Vector2, Vector2) onBottomQuadPoints)
    {
        ellipse(centerPos.x, centerPos.y, toInt(radiusXY.x), toInt(radiusXY.y), onTopQuadPoints, onBottomQuadPoints);
    }

    void ellipse(double centerXPos, double centerYPos, int radiusX, int radiusY,
        scope bool delegate(Vector2, Vector2) onTopQuadPoints,
        scope bool delegate(Vector2, Vector2) onBottomQuadPoints)
    {
        //John Kennedy fast Bresenham algorithm
        int centerX = toInt(centerXPos);
        int centerY = toInt(centerYPos);

        auto drawPoints = (int x, int y) {
            auto quadrand1Point = Vector2(centerX + x, centerY + y);
            auto quadrand2Point = Vector2(centerX - x, centerY + y);

            if (!onBottomQuadPoints(quadrand1Point, quadrand2Point))
            {
                return false;
            }

            auto quadrand3Point = Vector2(centerX - x, centerY - y);
            auto quadrand4Point = Vector2(centerX + x, centerY - y);

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

    void fillTriangle(Vector2 v01, Vector2 v02, Vector2 v03, RGBA fillColor)
    {
        changeColor(fillColor);
        scope (exit)
        {
            restoreColor;
        }

        fillTriangle(v01, v02, v03);
    }

    void fillTriangle(Vector2 v01, Vector2 v02, Vector2 v03)
    {
        void scanline(const ref Vector2 v1, const ref Vector2 v2, const ref Vector2 v3, bool isFlatBottom = true)
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

        Vector2[3] vertexByY = [v01, v02, v03];
        vertexByY[].sort!((v1, v2) => v1.y < v2.y);

        Vector2 vt1 = vertexByY[0];
        Vector2 vt2 = vertexByY[1];
        Vector2 vt3 = vertexByY[2];

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
            Vector2 temp = Vector2(tempX, tempY);
            scanline(vt1, vt2, temp);
            scanline(vt2, temp, vt3, false);
        }
    }

    void fillRect(Vector2 pos, double width, double height, RGBA fillColor = defaultColor)
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
        if (const err = renderer.drawFillRect(toInt(x), toInt(y), toInt(width), toInt(height)))
        {
            logger.errorf("Fill rect error. %s", err);
        }
    }

    void rect(Vector2 pos, double width, double height, RGBA color = defaultColor)
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

    void rect(Vector2 pos, double width, double height)
    {
        rect(pos.x, pos.y, width, height);
    }

    void rect(double x, double y, double width, double height)
    {
        if (const err = renderer.drawRect(toInt(x), toInt(y), toInt(width), toInt(height)))
        {
            logger.errorf("Draw rect error. %s", err);
        }
    }

    void rect(Vector2 pos, double width, double height, GraphicStyle style = GraphicStyle.simple)
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

    void bezier(Vector2 p0, RGBA color, scope Vector2 delegate(double v) onInterpValue, bool delegate(
            Vector2) onPoint = null)
    {
        changeColor(color);
        scope (exit)
        {
            restoreColor;
        }
        bezier(p0, onInterpValue, onPoint);
    }

    void bezier(Vector2 p0,
        scope Vector2 delegate(double v) onInterpValue,
        bool delegate(Vector2) onPoint = null,
        double delta = 0.01)
    {
        //enum delta = 0.01; //100 segments
        Vector2 start = p0;
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

    void bezier(Vector2 p0, Vector2 p1, Vector2 p2, scope bool delegate(
            Vector2) onPoint = null)
    {
        bezier(p0, (t) { return bezierInterp(p0, p1, p2, t); }, onPoint);
    }

    void bezier(Vector2 p0, Vector2 p1, Vector2 p2, Vector2 p3, scope bool delegate(
            Vector2) onPoint = null)
    {
        bezier(p0, (t) { return bezierInterp(p0, p1, p2, p3, t); }, onPoint);
    }

    private Vector2 bezierInterp(Vector2 p0, Vector2 p1, Vector2 p2, Vector2 p3, double t) @nogc nothrow pure @safe
    {
        const dt = 1 - t;
        Vector2 p0p1 = p0.scale(dt).add(p1.scale(t));
        Vector2 p1p2 = p1.scale(dt).add(p2.scale(t));
        Vector2 p2p3 = p2.scale(dt).add(p3.scale(t));
        Vector2 p0p1p2 = p0p1.scale(dt).add(p1p2.scale(t));
        Vector2 p1p2p3 = p1p2.scale(dt).add(p2p3.scale(t));
        Vector2 result = p0p1p2.scale(dt).add(p1p2p3.scale(t));

        return result;
    }

    private Vector2 bezierInterp(Vector2 p0, Vector2 p1, Vector2 p2, double t) @nogc nothrow pure @safe
    {
        const dt = 1 - t;
        Vector2 p0p1 = p0.scale(dt).add(p1.scale(t));
        Vector2 p1p2 = p1.scale(dt).add(p2.scale(t));
        Vector2 result = p0p1.scale(dt).add(p1p2.scale(t));
        return result;
    }

    void polygon(Vector2[] vertices)
    {
        if (vertices.length < 3)
        {
            return;
        }
        foreach (i, v; vertices)
        {
            if (i < vertices.length - 1)
            {
                line(v, vertices[i + 1]);
            }
        }
        line(vertices[$ - 1], vertices[0]);
    }

    bool fillPolyLines(Vector2[] vertexStart, Vector2[] vertexEnd, RGBA fillColor)
    {
        changeColor(fillColor);
        scope (exit)
        {
            restoreColor;
        }
        return fillPolyLines(vertexStart, vertexEnd);
    }

    bool fillPolyLines(Vector2[] vertexStart, Vector2[] vertexEnd)
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

    void clearScreen()
    {
        //isClearingInCycle
        if (const err = renderer.setDrawColor(screenColor.r, screenColor.g, screenColor.b, screenColor
                .aByte))
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
