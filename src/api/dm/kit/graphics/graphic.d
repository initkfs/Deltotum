module api.dm.kit.graphics.graphic;

import api.dm.com.com_result : ComResult;

import api.core.components.units.services.loggable_unit : LoggableUnit;
import api.core.utils.factories : ProviderFactory;

import api.dm.com.graphics.com_renderer : ComRenderer;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2f, Vec2i;
import math = api.dm.math;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

import Math = api.dm.math;

import api.math.pos2.flip : Flip;
import api.math.geom2.rect2 : Rect2f, Rect2f;
import api.math.geom2.line2 : Line2f;

import api.core.loggers.logging : Logging;
import std.conv : to;

import api.dm.com.graphics.com_texture : ComTexture;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.com.graphics.com_image_codec : ComImageCodec;
import api.dm.com.graphics.com_blend_mode : ComBlendMode;

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

    ComImageCodec[] comImageCodecs;

    this(Logging logging, ComRenderer renderer)
    {
        super(logging);

        //TODO opengl
        this.renderer = renderer;
    }

    pragma(inline, true)
    private int toInt(float value) pure @safe const nothrow
    {
        return cast(int) value;
    }

    Rect2f clip()
    {
        Rect2f clip;
        if (const err = renderer.getClipRect(clip))
        {
            import std.conv : text;

            throw new Exception(text("Error receiving clipping. ", err));
        }
        return clip;
    }

    void clip(Rect2f clipRect)
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

    ComResult readPixels(Rect2f bounds, ComSurface pixelBuffer) => renderer.readPixels(bounds, pixelBuffer);

    RGBA color()
    {
        ubyte r, g, b, a;
        if (const err = renderer.getDrawColor(r, g, b, a))
        {
            throw new Exception("Error getting current renderer color: " ~ err.toString);
        }
        return RGBA(r, g, b, (cast(float) a) / RGBA.maxColor);
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
            throw new Exception("Error setting render color: " ~ err.toString);
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
            logger.error("Error getting renderer blending mode: ", err);
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

    void line(float startX, float startY, float endX, float endY)
    {
        if (!renderer.drawLine(startX, startY, endX, endY))
        {
            throw new Exception("Line drawing error: " ~ renderer.getLastErrorNew);
        }
    }

    void line(Vec2f start, Vec2f end)
    {
        line(start.x, start.y, end.x, end.y);
    }

    void line(Vec2f start, Vec2f end, RGBA color = defaultColor)
    {
        line(start.x, start.y, end.x, end.y, color);
    }

    void line(Line2f ln)
    {
        line(ln.start, ln.end);
    }

    void line(Line2f ln, RGBA color = defaultColor)
    {
        line(ln.start, ln.end, color);
    }

    void line(float startX, float startY, float endX, float endY, RGBA color = defaultColor)
    {
        this.color(color);
        scope (exit)
        {
            restoreColor;
        }
        line(startX, startY, endX, endY);
    }

    void polygon(Vec2f[] points)
    {
        if (points.length == 0)
        {
            return;
        }

        if (!renderer.drawLines(points))
        {
            throw new Exception("Lines drawing error: " ~ renderer.getLastErrorNew);
        }

        if (points.length >= 3)
        {
            const last = points[$ - 1];
            const first = points[0];
            line(last.x, last.y, first.x, first.y);
        }
    }

    void polygon(Vec2f[] points, RGBA color = defaultColor) => polygon(points, points.length, color);

    void polygon(Vec2f[] points, size_t count, RGBA color = defaultColor)
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

    void point(float x, float y)
    {
        if (!renderer.drawPoint(x, y))
        {
            throw new Exception("Point drawing error: " ~ renderer.getLastErrorNew);
        }
    }

    void point(Vec2f p)
    {
        point(p.x, p.y);
    }

    void point(float x, float y, RGBA color = defaultColor)
    {
        this.color(color);
        scope (exit)
        {
            restoreColor;
        }

        point(x, y);
    }

    void point(Vec2f p, RGBA color = defaultColor)
    {
        point(p.x, p.y, color);
    }

    void points(Vec2f[] points)
    {
        if (points.length == 0)
        {
            return;
        }
        if (!renderer.drawPoints(points))
        {
            throw new Exception("float points drawing error: " ~ renderer.getLastErrorNew);
        }
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

        if (!renderer.drawPoints(p))
        {
            throw new Exception("Float points drawing error: " ~ renderer.getLastErrorNew);
        }
    }

    Vec2f[] linePoints(Vec2f start, Vec2f end)
    {
        return linePoints(start.x, start.y, end.x, end.y);
    }

    Vec2f[] linePoints(float startXPos, float startYPos, float endXPos, float endYPos)
    {
        import std.array : appender;

        auto points = appender!(Vec2f[]);
        linePoints(startXPos, startYPos, endXPos, endYPos, (p) {
            points ~= p;
            return true;
        });
        return points[];
    }

    void linePoints(Vec2f start, Vec2f end, scope bool delegate(
            Vec2f) onPoint)
    {
        linePoints(start.x, start.y, end.x, end.y, onPoint);
    }

    void linePoints(float startXPos, float startYPos, float endXPos, float endYPos, scope bool delegate(
            Vec2f) onPoint)
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
            if (!onPoint(Vec2f(startX, startY)))
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

    Vec2f[] circlePoints(Vec2f pos, int radius)
    {
        return circlePoints(pos.x, pos.y, radius);
    }

    Vec2f[] circlePoints(float centerXPos, float centerYPos, int radius)
    {
        import std.array : appender;

        auto points = appender!(Vec2f[]);
        circlePoints(centerXPos, centerYPos, radius, (p) {
            points ~= p;
            return true;
        });
        return points[];
    }

    void circlePoints(Vec2f pos, int radius, scope bool delegate(Vec2f) onPoint)
    {
        circlePoints(pos.x, pos.y, radius, onPoint);
    }

    void circlePoints(float centerXPos, float centerYPos, int radius, scope bool delegate(
            Vec2f) onPoint)
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
    void arc(float xCenter, float yCenter, float startAngleDeg, float endAngleDeg, float radiusArc)
    {
        assert(startAngleDeg != endAngleDeg);
        assert(startAngleDeg < endAngleDeg);

        immutable int radius = toInt(radiusArc);
        immutable int centerX = toInt(xCenter);
        immutable int centerY = toInt(yCenter);

        immutable angleRadIncr = 1.0 / radius;

        float startAngle = Math.degToRad(startAngleDeg);
        float endAngle = Math.degToRad(endAngleDeg);

        float angleRad = startAngle;
        while (angleRad <= endAngle)
        {
            immutable float x = radius * Math.cos(angleRad);
            immutable float y = radius * Math.sin(angleRad);
            point(centerX + x, centerY + y);
            angleRad += angleRadIncr;
        }
    }

    void fillCircle(Vec2f center, float radius)
    {
        circle(center.x, center.y, radius, true);
    }

    void fillCircle(float centerX, float centerY, float radius)
    {
        circle(centerX, centerY, radius, true);
    }

    void fillCircle(float centerX, float centerY, float radius, RGBA color = defaultColor)
    {
        circle(centerX, centerY, radius, color, true);
    }

    void circle(float centerX, float centerY, float radius, bool isFill = false)
    {
        ellipse(Vec2f(centerX, centerY), Vec2f(radius, radius), isFill, isFill);
    }

    void circle(float centerX, float centerY, float radius, RGBA color = defaultColor, bool isFill = false)
    {
        ellipse(Vec2f(centerX, centerY), Vec2f(radius, radius), color, isFill, isFill);
    }

    void circle(float centerX, float centerY, float radius)
    {
        int radiusInt = toInt(radius);
        ellipse(centerX, centerY, radiusInt, radiusInt);
    }

    void ellipse(Vec2f centerPos, Vec2f radiusXY, RGBA color, bool isFillTop = false, bool isFillBottom = false)
    {
        this.color(color);
        scope (exit)
        {
            restoreColor;
        }
        ellipse(centerPos, radiusXY, isFillTop, isFillBottom);
    }

    void ellipse(Vec2f centerPos, Vec2f radiusXY, bool isFillTop = false, bool isFillBottom = false)
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

    void ellipse(Vec2f centerPos, Vec2f radiusXY)
    {
        ellipse(centerPos.x, centerPos.y, toInt(radiusXY.x), toInt(radiusXY.y));
    }

    void ellipse(float centerX, float centerY, int radiusX, int radiusY)
    {
        ellipse(centerX, centerY, radiusX, radiusY,
            (p1, p2) { point(p1); point(p2); return true; },
            (p1, p2) { point(p1); point(p2); return true; });
    }

    void ellipse(Vec2f centerPos, Vec2f radiusXY,
        scope bool delegate(Vec2f, Vec2f) onTopQuadPoints,
        scope bool delegate(Vec2f, Vec2f) onBottomQuadPoints)
    {
        ellipse(centerPos.x, centerPos.y, toInt(radiusXY.x), toInt(radiusXY.y), onTopQuadPoints, onBottomQuadPoints);
    }

    void ellipse(float centerXPos, float centerYPos, int radiusX, int radiusY,
        scope bool delegate(Vec2f, Vec2f) onTopQuadPoints,
        scope bool delegate(Vec2f, Vec2f) onBottomQuadPoints)
    {
        //John Kennedy fast Bresenham algorithm
        int centerX = toInt(centerXPos);
        int centerY = toInt(centerYPos);

        auto drawPoints = (int x, int y) {
            auto quadrand1Point = Vec2f(centerX + x, centerY + y);
            auto quadrand2Point = Vec2f(centerX - x, centerY + y);

            if (!onBottomQuadPoints(quadrand1Point, quadrand2Point))
            {
                return false;
            }

            auto quadrand3Point = Vec2f(centerX - x, centerY - y);
            auto quadrand4Point = Vec2f(centerX + x, centerY - y);

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

    void fillTriangle(Vec2f v01, Vec2f v02, Vec2f v03, RGBA fillColor)
    {
        color(fillColor);
        scope (exit)
        {
            restoreColor;
        }

        fillTriangle(v01, v02, v03);
    }

    void fillTriangle(Vec2f v01, Vec2f v02, Vec2f v03)
    {
        void scanline(const ref Vec2f v1, const ref Vec2f v2, const ref Vec2f v3, bool isFlatBottom = true)
        {
            float lineGradient1 = 0;
            float lineGradient2 = 0;
            float x1 = 0;
            float x2 = 0;
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

        Vec2f[3] vertexByY = [v01, v02, v03];
        vertexByY[].sort!((v1, v2) => v1.y < v2.y);

        Vec2f vt1 = vertexByY[0];
        Vec2f vt2 = vertexByY[1];
        Vec2f vt3 = vertexByY[2];

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
            Vec2f temp = Vec2f(tempX, tempY);
            scanline(vt1, vt2, temp);
            scanline(vt2, temp, vt3, false);
        }
    }

    void fillRect(Rect2f bounds)
    {
        fillRect(bounds.x, bounds.y, bounds.width, bounds.height);
    }

    void fillRect(Rect2f bounds, RGBA color)
    {
        fillRect(bounds.x, bounds.y, bounds.width, bounds.height, color);
    }

    void fillRect(Vec2f pos, float width, float height, RGBA fillColor = defaultColor)
    {
        fillRect(pos.x, pos.y, width, height, fillColor);
    }

    void fillRect(float x, float y, float width, float height, RGBA fillColor = defaultColor)
    {
        color(fillColor);
        scope (exit)
        {
            restoreColor;
        }
        fillRect(x, y, width, height);
    }

    void fillRect(float x, float y, float width, float height)
    {
        if (!renderer.drawFillRect(x, y, width, height))
        {
            throw new Exception("Fill rect error: " ~ renderer.getLastErrorNew);
        }
    }

    void fillRects(Rect2f[] rects, RGBA fillColor = defaultColor)
    {
        color(fillColor);
        scope (exit)
        {
            restoreColor;
        }
        if (!renderer.drawFillRects(rects))
        {
            throw new Exception("Fill rects error: " ~ renderer.getLastErrorNew);
        }
    }

    void rect(Vec2f pos, float width, float height, RGBA color = defaultColor)
    {
        rect(pos.x, pos.y, width, height, color);
    }

    void rect(float x, float y, float width, float height, RGBA color = defaultColor)
    {
        this.color(color);
        scope (exit)
        {
            restoreColor;
        }
        rect(x, y, width, height);
    }

    void rect(Rect2f bounds)
    {
        rect(bounds.x, bounds.y, bounds.width, bounds.height);
    }

    void rect(Vec2f pos, float width, float height)
    {
        rect(pos.x, pos.y, width, height);
    }

    void rect(float x, float y, float width, float height)
    {
        if (!renderer.drawRect(x, y, width, height))
        {
            throw new Exception("Draw rect error: " ~ renderer.getLastErrorNew);
        }
    }

    void rect(Vec2f pos, float width, float height, GraphicStyle style = GraphicStyle.simple)
    {
        rect(pos.x, pos.y, width, height, style);
    }

    void rect(float x, float y, float width, float height, GraphicStyle style = GraphicStyle
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

    void bezier(Vec2f p0, RGBA color, scope Vec2f delegate(float v) onInterpValue, bool delegate(
            Vec2f) onPoint = null)
    {
        this.color(color);
        scope (exit)
        {
            restoreColor;
        }
        bezier(p0, onInterpValue, onPoint);
    }

    void bezier(Vec2f p0,
        scope Vec2f delegate(float v) onInterpValue,
        bool delegate(Vec2f) onPoint = null,
        float delta = 0.01)
    {
        //enum delta = 0.01; //100 segments
        Vec2f start = p0;
        //TODO exact comparison of floats?
        for (float i = 0; i < 1; i += delta)
        {
            auto end = onInterpValue(i);
            if (onPoint !is null && !onPoint(end))
            {
                start = end;
                continue;
            }
            line(start.x, start.y, end.x, end.y);
            start = end;
        }
    }

    void bezier(Vec2f p0, Vec2f p1, Vec2f p2, scope bool delegate(
            Vec2f) onPoint = null)
    {
        bezier(p0, (t) { return bezierInterp(p0, p1, p2, t); }, onPoint);
    }

    void bezier(Vec2f p0, Vec2f p1, Vec2f p2, Vec2f p3, scope bool delegate(
            Vec2f) onPoint = null)
    {
        bezier(p0, (t) { return bezierInterp(p0, p1, p2, p3, t); }, onPoint);
    }

    private Vec2f bezierInterp(Vec2f p0, Vec2f p1, Vec2f p2, Vec2f p3, float t) nothrow pure @safe
    {
        const dt = 1 - t;
        Vec2f p0p1 = p0.scale(dt).add(p1.scale(t));
        Vec2f p1p2 = p1.scale(dt).add(p2.scale(t));
        Vec2f p2p3 = p2.scale(dt).add(p3.scale(t));
        Vec2f p0p1p2 = p0p1.scale(dt).add(p1p2.scale(t));
        Vec2f p1p2p3 = p1p2.scale(dt).add(p2p3.scale(t));
        Vec2f result = p0p1p2.scale(dt).add(p1p2p3.scale(t));

        return result;
    }

    private Vec2f bezierInterp(Vec2f p0, Vec2f p1, Vec2f p2, float t) nothrow pure @safe
    {
        const dt = 1 - t;
        Vec2f p0p1 = p0.scale(dt).add(p1.scale(t));
        Vec2f p1p2 = p1.scale(dt).add(p2.scale(t));
        Vec2f result = p0p1.scale(dt).add(p1p2.scale(t));
        return result;
    }

    bool fillPolyLines(Vec2f[] vertexStart, Vec2f[] vertexEnd, RGBA fillColor)
    {
        color(fillColor);
        scope (exit)
        {
            restoreColor;
        }
        return fillPolyLines(vertexStart, vertexEnd);
    }

    bool fillPolyLines(Vec2f[] vertexStart, Vec2f[] vertexEnd)
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
        if (!renderer.tryPresent)
        {
            throw new Exception("Error presenting renderer: " ~ renderer.getLastErrorNew);
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

        if (!renderer.tryClearAndFill)
        {
            throw new Exception("Error clearing error: " ~ renderer.getLastErrorNew);
            //TODO logging in main loop?
        }
    }

    Rect2f viewport()
    {
        Rect2f v;
        if (const err = renderer.getViewport(v))
        {
            throw new Exception("Error getting renderer viewport: " ~ err);
        }
        return v;
    }

    void viewport(Rect2f v)
    {
        if (const err = renderer.setViewport(v))
        {
            throw new Exception("Error setting renderer viewport: " ~ err);
        }
    }

    void scale(float scaleX, float scaleY)
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

    Rect2f renderBounds()
    {
        int outputWidth;
        int outputHeight;

        if (const err = renderer.getOutputSize(outputWidth, outputHeight))
        {
            logger.error("Error getting renderer output size: ", err);
            return Rect2f.init;
        }

        return Rect2f(0, 0, outputWidth, outputHeight);
    }
}
