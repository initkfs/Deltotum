module api.dm.kit.graphics.canvases.graphic_canvas;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2f;

struct GStop
{
    float offset = 0;
    RGBA color;

    this(float offset, RGBA color)
    {
        this.offset = offset;
        this.color = color;
    }

    this(float offset, string colorHex)
    {
        this.offset = offset;
        this.color = RGBA.hex(colorHex);
    }
}

struct GStopBuilder
{
    GStop[] stops;

    Vec2f start;
    float innerRadius = 0;
    Vec2f end;
    float outerRadius = 0;

    this(size_t reserveCount, Vec2f start, float innerRadius = 0, Vec2f end, float outerRadius = 0)
    {
        stops.reserve(reserveCount);
        this.start = start;
        this.innerRadius = innerRadius;
        this.end = end;
        this.outerRadius = outerRadius;
    }

    //https://developer.mozilla.org/en-US/docs/Web/API/CanvasGradient/addColorStop
    void addColorStop(float offset, string colorHex)
    {
        stops ~= GStop(offset, colorHex);
    }

    void addColorStop(float offset, RGBA color)
    {
        stops ~= GStop(offset, color);
    }
}

/**
 * Authors: initkfs
 */
interface GraphicCanvas
{
    enum LineEnd
    {
        butt,
        round,
        square
    }

    enum LineJoin
    {
        miter,
        round,
        bevel
    }

    //Unification with JS Canvas API
    alias fillStyle = color;
    alias strokeStyle = color;

    //https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/createLinearGradient
    final GStopBuilder createLinearGradient(float x0, float y0, float x1, float y1)
    {
        return GStopBuilder(2, Vec2f(x0, y0), 0, Vec2f(x1, y1), 0);
    }

    final void linearGradient(GStopBuilder builder, void delegate() onPattern)
    {
        linearGradient(builder.start, builder.end, builder.stops, onPattern);
    }
    
    //https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/createRadialGradient
    final GStopBuilder createRadialGradient(float innerCenterX, float innerCenterY, float innerRadius, float outerCenterX, float outerCenterY, float outerRadius)
    {
        return GStopBuilder(2, Vec2f(innerCenterX, innerCenterY), innerRadius, Vec2f(outerCenterX, outerCenterY), outerRadius);
    }

    final void radialGradient(GStopBuilder builder, void delegate() onPattern)
    {
        radialGradient(builder.start, builder.innerRadius, builder.end, builder.outerRadius, builder.stops, onPattern);
    }
    
    void beginPath();
    void closePath();

    bool isPointInPath(float x, float y);

    RGBA color();
    void color(RGBA rgba);

    final void color(string hex)
    {
        color(RGBA.hex(hex));
    }

    void restoreColor();
    void clear(RGBA color);

    void lineWidth(float width);

    void save();
    void restore();
    void reset();

    void translate(float x, float y);
    void scale(float sx, float sy);
    void rotateRad(float angleRad);

    void lineEnd(LineEnd end);
    void lineJoin(LineJoin join);

    void moveTo(float x, float y);
    void moveTo(Vec2f pos);

    void lineTo(float x, float y);
    void lineTo(Vec2f pos);

    void stroke();
    void strokePreserve();
    void fill();
    void fillPreserve();

    void clip();

    void rect(float x, float y, float width, float height);
    void fillRect(float x, float y, float width, float height);
    void strokeRect(float x, float y, float width, float height);
    void clearRect(float x, float y, float width, float height);

    void fillTriangle(float x1, float y1, float x2, float y2, float x3, float y3);

    void arc(float xc, float yc, float radius, float angle1Rad, float angle2Rad);

    void bezierCurveTo(float x1, float y1, float x2, float y2, float x3, float y3);

    void linearGradient(float x0, float y0, float x1, float y1, GStop[] stopPoints, void delegate() onPattern);
    void linearGradient(Vec2f start, Vec2f end, GStop[] stopPoints, void delegate() onPattern);
    void radialGradient(Vec2f innerCenter, float innerRadius, Vec2f outerCenter, float outerRadius, GStop[] stopPoints, void delegate() onPattern);

    void text(string text);
    void strokeText(string text, float x, float y);
    void fillText(string text, float x, float y);
    void fontFace(string name);
    void fontSize(double size);

    void miterLimit(double size);
}
