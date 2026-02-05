module api.dm.kit.assets.svg.svg_icon;

import api.dm.kit.assets.xml.xml_elements : XmlAttr, XmlElement, XmlException;
import api.dm.kit.assets.svg.svg_parser : SvgParser;
import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;
import api.dm.kit.graphics.colors.rgba : RGBA;

import Math = api.math;

//TODO refactor
import std;

/**
 * Authors: initkfs
 */

class SvgIcon : VectorTexture
{
    string svgText;
    GraphicCanvas canvas;
    RGBA color;
    bool isUseSolidColor = true;
    float lineWidth = 0;

    this(float size, string text, RGBA color)
    {
        super(size, size);
        this.svgText = text;

        if (size == 0)
        {
            throw new Exception("Icon size must not be zero");
        }
        this.color = color;
    }

    override void createContent()
    {
        this.canvas = _gContext;
        assert(this.canvas);

        if (svgText.length == 0)
        {
            return;
        }

        import api.dm.kit.assets.svg.svg_parser : SvgParser;

        auto parser = new SvgParser;
        auto svgRoot = parser.parse(svgText);

        float targetWidth = width;
        float targetHeight = height;

        float svgWidth = parseLength(svgRoot.getAttr("width"), targetWidth);
        float svgHeight = parseLength(svgRoot.getAttr("height"), targetHeight);

        float viewBoxX = 0, viewBoxY = 0, viewBoxWidth = svgWidth, viewBoxHeight = svgHeight;
        string viewBoxStr = svgRoot.getAttr("viewBox");
        if (!viewBoxStr.empty)
        {
            auto parts = viewBoxStr.split().map!(s => s.strip())
                .filter!(s => !s.empty)
                .array();
            if (parts.length >= 4)
            {
                viewBoxX = parts[0].to!float;
                viewBoxY = parts[1].to!float;
                viewBoxWidth = parts[2].to!float;
                viewBoxHeight = parts[3].to!float;
            }
        }

        canvas.clear(RGBA.transparent);

        canvas.color = color;
        if (lineWidth != 0)
        {
            canvas.lineWidth = lineWidth;
        }

        canvas.save;

        float scaleX = targetWidth / viewBoxWidth;
        float scaleY = targetHeight / viewBoxHeight;

        // Uniform scaling - preserve aspect ratio
        float uniformScale = Math.min(scaleX, scaleY);
        float offsetX = (targetWidth - viewBoxWidth * uniformScale) / 2;
        float offsetY = (targetHeight - viewBoxHeight * uniformScale) / 2;

        canvas.translate(offsetX, offsetY);
        canvas.scale(uniformScale, uniformScale);
        canvas.translate(-viewBoxX, -viewBoxY);

        renderChildren(svgRoot);

        canvas.restore;
    }

    private void renderChildren(XmlElement parent)
    {
        foreach (child; parent.children)
        {
            renderElement(child);
        }
    }

    private void renderElement(XmlElement element)
    {
        switch (element.name)
        {
            case "path":
                renderPath(element);
                break;
            case "rect":
                renderRect(element);
                break;
            case "circle":
                renderCircle(element);
                break;
            case "ellipse":
                renderEllipse(element);
                break;
            case "line":
                renderLine(element);
                break;
            case "polyline":
                renderPolyline(element);
                break;
            case "polygon":
                renderPolygon(element);
                break;
            case "g":
                renderGroup(element);
                break;
            case "text":
                renderText(element);
                break;
            default:
                throw new Exception("Unknown element: " ~ element.name);
                // Skip unknown elements
                // break;
        }
    }

    private void parseStyle(XmlElement element, bool skipApply = false)
    {
        string style = element.getAttr("style");
        if (style.length != 0)
        {
            auto styles = parseStyleString(style);
            foreach (key, value; styles)
            {
                applyStyle(key, value);
            }
        }

        static immutable styleAttrs = [
            "bug_outline", "stroke", "stroke-width", "stroke-linecap",
            "stroke-linejoin", "opacity", "fill-opacity", "stroke-opacity"
        ];

        foreach (attr; styleAttrs)
        {
            string value = element.getAttr(attr);
            if (value.length > 0)
            {
                applyStyle(attr, value);
            }
        }

        if (!skipApply)
        {
            // Apply stroke/fill based on style
            applyPathOperations(element);
        }
    }

    private void renderPath(XmlElement path)
    {
        string d = path.getAttr("d");
        if (d.length == 0)
        {
            return;
        }

        parseStyle(path);
        canvas.beginPath;
        parsePathData(d);
        applyPathOperations(path);
    }

    private void parsePathData(string d)
    {
        import std.regex : regex, split, matchAll;
        import std.array : array;
        import std.conv : to, parse;
        import std.string : strip;
        import std.math : PI, cos, sin;
        import std.algorithm : map, filter;

        import Ascii = std.ascii;

        canvas.beginPath;

        float currentX = 0, currentY = 0;
        float startX = 0, startY = 0;
        float lastControlX = 0, lastControlY = 0;

        size_t i = 0;
        char lastCommand = '\0';

        while (i < d.length)
        {
            // Skip whitespace and commas
            while (i < d.length && (Ascii.isWhite(d[i]) || d[i] == ','))
                i++;
            if (i >= d.length)
                break;

            // Check command chars
            char c = d[i];
            bool isCommand = (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z');

            if (isCommand)
            {
                lastCommand = c;
                i++;
            }
            else if (lastCommand == '\0')
            {
                throw new Exception("Invalid path data: expected command: " ~ d);
            }

            float[] params = parseParams(d, i);

            switch (lastCommand)
            {
                // Move To
                case 'M': // absolute
                    executeMoveTo(params, false, currentX, currentY, startX, startY);
                    lastCommand = 'L'; // Subsequent params are treated as LineTo
                    break;
                case 'm': // relative
                    executeMoveTo(params, true, currentX, currentY, startX, startY);
                    lastCommand = 'l'; // Subsequent params are treated as LineTo
                    break;
                    // Line To
                case 'L': // absolute
                    executeLineTo(params, false, currentX, currentY);
                    break;
                case 'l': // relative
                    executeLineTo(params, true, currentX, currentY);
                    break;

                    // Horizontal Line To
                case 'H': // absolute
                    executeHorizontalLineTo(params, false, currentX, currentY);
                    break;
                case 'h': // relative
                    executeHorizontalLineTo(params, true, currentX, currentY);
                    break;

                    // Vertical Line To
                case 'V': // absolute
                    executeVerticalLineTo(params, false, currentX, currentY);
                    break;
                case 'v': // relative
                    executeVerticalLineTo(params, true, currentX, currentY);
                    break;
                    // Cubic Bezier Curve To
                case 'C': // absolute
                    executeCubicBezierTo(params, false, currentX, currentY, lastControlX, lastControlY);
                    break;
                case 'c': // relative
                    executeCubicBezierTo(params, true, currentX, currentY, lastControlX, lastControlY);
                    break;
                    // Smooth Cubic Bezier Curve To
                case 'S': // absolute
                    executeSmoothCubicBezierTo(params, false, currentX, currentY, lastControlX, lastControlY);
                    break;
                case 's': // relative
                    executeSmoothCubicBezierTo(params, true, currentX, currentY, lastControlX, lastControlY);
                    break;
                    // Quadratic Bezier Curve To
                case 'Q': // absolute
                    executeQuadraticBezierTo(params, false, currentX, currentY, lastControlX, lastControlY);
                    break;
                case 'q': // relative
                    executeQuadraticBezierTo(params, true, currentX, currentY, lastControlX, lastControlY);
                    break;
                    // Smooth Quadratic Bezier Curve To
                case 'T': // absolute
                    executeSmoothQuadraticBezierTo(params, false, currentX, currentY, lastControlX, lastControlY);
                    break;
                case 't': // relative
                    executeSmoothQuadraticBezierTo(params, true, currentX, currentY, lastControlX, lastControlY);
                    break;
                    // Elliptical Arc To
                case 'A': // absolute
                    executeArcTo(params, false, currentX, currentY);
                    break;
                case 'a': // relative
                    executeArcTo(params, true, currentX, currentY);
                    break;
                    // Close Path
                case 'Z':
                case 'z':
                    canvas.closePath;
                    currentX = startX;
                    currentY = startY;
                    break;
                default:
                    throw new Exception("Unknown path command: " ~ lastCommand);
            }
        }
    }

    private float[] parseParams(string d, ref size_t i)
    {
        float[] params;

        import Ascii = std.ascii;

        while (i < d.length)
        {
            // Skip whitespace and commas
            while (i < d.length && (Ascii.isWhite(d[i]) || d[i] == ','))
                i++;

            //TODO remove duplications
            // Check commain chars c
            if (i < d.length)
            {
                char c = d[i];
                if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z'))
                {
                    break;
                }
            }

            // Parse number
            size_t start = i;
            bool hasExp = false;
            bool hasDot = false;

            while (i < d.length)
            {
                char c = d[i];
                if (c == '+' || c == '-')
                {
                    // Sign can only appear at start of number or after exponent
                    if (i > start && (d[i - 1] != 'e' && d[i - 1] != 'E'))
                    {
                        break;
                    }
                }
                else if (c == '.')
                {
                    if (hasDot)
                        break; // Only one dot allowed
                    hasDot = true;
                }
                else if (c == 'e' || c == 'E')
                {
                    if (hasExp)
                        break; // Only one exponent allowed
                    hasExp = true;
                }
                else if (!c.isDigit)
                {
                    break;
                }
                i++;
            }

            if (i > start)
            {
                try
                {
                    string numStr = d[start .. i];
                    float value = parse!float(numStr);
                    params ~= value;
                }
                catch (Exception e)
                {
                    throw new Exception("Failed to parse number: " ~ d[start .. i] ~ " - " ~ e.msg);
                }
            }
            else
            {
                break;
            }
        }

        return params;
    }

    private void executeMoveTo(float[] params, bool relative,
        ref float currentX, ref float currentY,
        ref float startX, ref float startY)
    {
        if (params.length < 2)
            return;

        for (size_t j = 0; j + 1 < params.length; j += 2)
        {
            float x = params[j];
            float y = params[j + 1];

            if (relative)
            {
                x += currentX;
                y += currentY;
            }

            if (j == 0) // First move
            {
                canvas.moveTo(x, y);
                startX = x;
                startY = y;
            }
            else // Subsequent coordinates are implicit LineTo
            {
                canvas.lineTo(x, y);
            }

            currentX = x;
            currentY = y;
        }
    }

    private void executeLineTo(float[] params, bool relative,
        ref float currentX, ref float currentY)
    {
        for (size_t j = 0; j + 1 < params.length; j += 2)
        {
            float x = params[j];
            float y = params[j + 1];

            if (relative)
            {
                x += currentX;
                y += currentY;
            }

            canvas.lineTo(x, y);
            currentX = x;
            currentY = y;
        }
    }

    private void executeHorizontalLineTo(float[] params, bool relative,
        ref float currentX, ref float currentY)
    {
        foreach (x; params)
        {
            float targetX = relative ? currentX + x : x;
            canvas.lineTo(targetX, currentY);
            currentX = targetX;
        }
    }

    private void executeVerticalLineTo(float[] params, bool relative,
        ref float currentX, ref float currentY)
    {
        foreach (y; params)
        {
            float targetY = relative ? currentY + y : y;
            canvas.lineTo(currentX, targetY);
            currentY = targetY;
        }
    }

    private void executeCubicBezierTo(float[] params, bool relative,
        ref float currentX, ref float currentY,
        ref float lastControlX, ref float lastControlY)
    {
        for (size_t j = 0; j + 5 < params.length; j += 6)
        {
            float x1 = params[j];
            float y1 = params[j + 1];
            float x2 = params[j + 2];
            float y2 = params[j + 3];
            float x = params[j + 4];
            float y = params[j + 5];

            if (relative)
            {
                x1 += currentX;
                y1 += currentY;
                x2 += currentX;
                y2 += currentY;
                x += currentX;
                y += currentY;
            }

            canvas.bezierCurveTo(x1, y1, x2, y2, x, y);

            lastControlX = x2;
            lastControlY = y2;
            currentX = x;
            currentY = y;
        }
    }

    private void executeSmoothCubicBezierTo(float[] params, bool relative,
        ref float currentX, ref float currentY,
        ref float lastControlX, ref float lastControlY)
    {
        for (size_t j = 0; j + 3 < params.length; j += 4)
        {
            float x1 = currentX + (currentX - lastControlX);
            float y1 = currentY + (currentY - lastControlY);

            float x2 = params[j];
            float y2 = params[j + 1];
            float x = params[j + 2];
            float y = params[j + 3];

            if (relative)
            {
                x2 += currentX;
                y2 += currentY;
                x += currentX;
                y += currentY;
            }

            canvas.bezierCurveTo(x1, y1, x2, y2, x, y);

            lastControlX = x2;
            lastControlY = y2;
            currentX = x;
            currentY = y;
        }
    }

    private void executeQuadraticBezierTo(float[] params, bool relative,
        ref float currentX, ref float currentY,
        ref float lastControlX, ref float lastControlY)
    {
        for (size_t j = 0; j + 3 < params.length; j += 4)
        {
            float x1 = params[j];
            float y1 = params[j + 1];
            float x = params[j + 2];
            float y = params[j + 3];

            if (relative)
            {
                x1 += currentX;
                y1 += currentY;
                x += currentX;
                y += currentY;
            }

            // Convert quadratic to cubic
            float cx1 = currentX + (2.0f / 3.0f) * (x1 - currentX);
            float cy1 = currentY + (2.0f / 3.0f) * (y1 - currentY);
            float cx2 = x + (2.0f / 3.0f) * (x1 - x);
            float cy2 = y + (2.0f / 3.0f) * (y1 - y);

            canvas.bezierCurveTo(cx1, cy1, cx2, cy2, x, y);

            lastControlX = x1;
            lastControlY = y1;
            currentX = x;
            currentY = y;
        }
    }

    private void executeSmoothQuadraticBezierTo(float[] params, bool relative,
        ref float currentX, ref float currentY,
        ref float lastControlX, ref float lastControlY)
    {
        for (size_t j = 0; j + 1 < params.length; j += 2)
        {
            // Calculate reflection of last control point
            float x1 = currentX + (currentX - lastControlX);
            float y1 = currentY + (currentY - lastControlY);

            float x = params[j];
            float y = params[j + 1];

            if (relative)
            {
                x += currentX;
                y += currentY;
            }

            // Convert quadratic to cubic
            float cx1 = currentX + (2.0f / 3.0f) * (x1 - currentX);
            float cy1 = currentY + (2.0f / 3.0f) * (y1 - currentY);
            float cx2 = x + (2.0f / 3.0f) * (x1 - x);
            float cy2 = y + (2.0f / 3.0f) * (y1 - y);

            canvas.bezierCurveTo(cx1, cy1, cx2, cy2, x, y);

            lastControlX = x1;
            lastControlY = y1;
            currentX = x;
            currentY = y;
        }
    }

    private void executeArcTo(float[] params, bool relative,
        ref float currentX, ref float currentY)
    {
        // Tsimplified version
        for (size_t j = 0; j + 6 < params.length; j += 7)
        {
            float rx = params[j]; // x-radius
            float ry = params[j + 1]; // y-radius
            float xAxisRotation = params[j + 2] * (PI / 180.0f); // degrees to radians
            bool largeArcFlag = params[j + 3] != 0;
            bool sweepFlag = params[j + 4] != 0;
            float x = params[j + 5];
            float y = params[j + 6];

            if (relative)
            {
                x += currentX;
                y += currentY;
            }

            if (rx <= 0 || ry <= 0)
            {
                // Invalid radius - draw line
                canvas.lineTo(x, y);
            }
            else
            {
                // Simplified
                drawApproximateArc(currentX, currentY, x, y, rx, ry,
                    xAxisRotation, largeArcFlag, sweepFlag);
            }

            currentX = x;
            currentY = y;
        }
    }

    private void drawApproximateArc(float startX, float startY, float endX, float endY,
        float rx, float ry, float xAxisRotation,
        bool largeArcFlag, bool sweepFlag)
    {
        // simplified, simple approximation: draw line if radii are too small
        if (rx < 0.1 || ry < 0.1)
        {
            canvas.lineTo(endX, endY);
            return;
        }

        // Calculate midpoint and control points for approximation
        float midX = (startX + endX) / 2;
        float midY = (startY + endY) / 2;

        // Simple bezier approximation (not accurate but works for many cases)
        float dx = endX - startX;
        float dy = endY - startY;
        float dist = sqrt(dx * dx + dy * dy);

        if (dist > 0)
        {
            float scale = min(rx, ry) / dist * 0.5f;

            float ctrl1X = startX + dx * 0.5f - dy * scale;
            float ctrl1Y = startY + dy * 0.5f + dx * scale;
            float ctrl2X = startX + dx * 0.5f + dy * scale;
            float ctrl2Y = startY + dy * 0.5f - dx * scale;

            canvas.bezierCurveTo(ctrl1X, ctrl1Y, ctrl2X, ctrl2Y, endX, endY);
        }
        else
        {
            canvas.lineTo(endX, endY);
        }
    }

    private void renderRect(XmlElement rect)
    {
        float x = parseLength(rect.getAttr("x"), 0);
        float y = parseLength(rect.getAttr("y"), 0);
        float width = parseLength(rect.getAttr("width"), 0);
        float height = parseLength(rect.getAttr("height"), 0);
        float rx = parseLength(rect.getAttr("rx"), 0);
        float ry = parseLength(rect.getAttr("ry"), rx); // ry defaults to rx

        parseStyle(rect);

        if (rx > 0 || ry > 0)
        {
            // Rounded rectangle - simplified
            canvas.beginPath();
            canvas.rect(x, y, width, height);
        }
        else
        {
            canvas.beginPath();
            canvas.rect(x, y, width, height);
        }

        applyPathOperations(rect);
    }

    private void renderCircle(XmlElement circle)
    {
        float cx = parseLength(circle.getAttr("cx"), 0);
        float cy = parseLength(circle.getAttr("cy"), 0);
        float r = parseLength(circle.getAttr("r"), 0);

        parseStyle(circle);
        canvas.beginPath();
        canvas.arc(cx, cy, r, 0, 2 * PI);
        applyPathOperations(circle);
    }

    private void renderEllipse(XmlElement ellipse)
    {
        float cx = parseLength(ellipse.getAttr("cx"), 0);
        float cy = parseLength(ellipse.getAttr("cy"), 0);
        float rx = parseLength(ellipse.getAttr("rx"), 0);
        float ry = parseLength(ellipse.getAttr("ry"), 0);

        parseStyle(ellipse);
        canvas.beginPath();
        // Simplified: draw as circle scaled differently
        canvas.save();
        canvas.translate(cx, cy);
        canvas.scale(rx / ry, 1);
        canvas.arc(0, 0, ry, 0, 2 * PI);
        canvas.restore();
        applyPathOperations(ellipse);
    }

    private void renderLine(XmlElement line)
    {
        float x1 = parseLength(line.getAttr("x1"), 0);
        float y1 = parseLength(line.getAttr("y1"), 0);
        float x2 = parseLength(line.getAttr("x2"), 0);
        float y2 = parseLength(line.getAttr("y2"), 0);

        parseStyle(line);
        canvas.beginPath();
        canvas.moveTo(x1, y1);
        canvas.lineTo(x2, y2);
        applyPathOperations(line);
    }

    private void renderPolyline(XmlElement polyline)
    {
        string points = polyline.getAttr("points");
        if (points.empty)
            return;

        parseStyle(polyline);
        canvas.beginPath;

        auto coords = parsePoints(points);
        if (coords.length >= 2)
        {
            canvas.moveTo(coords[0], coords[1]);
            for (size_t i = 2; i + 1 < coords.length; i += 2)
            {
                canvas.lineTo(coords[i], coords[i + 1]);
            }
        }

        applyPathOperations(polyline);
    }

    private void renderPolygon(XmlElement polygon)
    {
        string points = polygon.getAttr("points");
        if (points.empty)
            return;

        parseStyle(polygon);
        canvas.beginPath();

        auto coords = parsePoints(points);
        if (coords.length >= 2)
        {
            canvas.moveTo(coords[0], coords[1]);
            for (size_t i = 2; i + 1 < coords.length; i += 2)
            {
                canvas.lineTo(coords[i], coords[i + 1]);
            }
            canvas.closePath();
        }

        applyPathOperations(polygon);
    }

    private void renderGroup(XmlElement group)
    {
        canvas.save;

        string transform = group.getAttr("transform");
        if (!transform.empty)
        {
            applyTransform(transform);
        }

        parseStyle(group, true); // parse but don't apply yet
        renderChildren(group);
        canvas.restore;
    }

    private void renderText(XmlElement text)
    {
        float x = parseLength(text.getAttr("x"), 0);
        float y = parseLength(text.getAttr("y"), 0);

        parseStyle(text);

        string content = text.text;
        if (!content.empty)
        {
            canvas.fillText(content, x, y);
        }

        renderChildren(text);
    }

    private void applyPathOperations(XmlElement element)
    {
        string stroke = element.getAttr("stroke");
        if (stroke.empty)
        {
            auto styles = parseStyleString(element.getAttr("style"));
            if ("stroke" in styles)
                stroke = styles["stroke"];
        }

        if (stroke != "none" && !stroke.empty)
        {
            canvas.stroke;
        }

        string fill = element.getAttr("fill");
        if (fill.empty)
        {
            auto styles = parseStyleString(element.getAttr("style"));
            if ("fill" in styles)
                fill = styles["fill"];
        }

        if (fill != "none" && !fill.empty)
        {
            if (fill == "currentColor")
            {
                // Use current color
                canvas.fill;
            }
            else
            {
                // Parse color
                try
                {
                    canvas.color(fill);
                    canvas.fill;
                    canvas.restoreColor;
                }
                catch (Exception)
                {
                    throw new Exception("Couldn't parse color: " ~ fill);
                }
            }
        }
    }

    private string[string] parseStyleString(string style)
    {
        string[string] result;

        auto declarations = style.split(";");
        foreach (decl; declarations)
        {
            auto parts = decl.split(":");
            if (parts.length >= 2)
            {
                string key = parts[0].strip();
                string value = parts[1].strip();
                result[key] = value;
            }
        }

        return result;
    }

    private void applyStyle(string key, string value)
    {
        switch (key)
        {
            case "stroke":
                if (!isUseSolidColor && value != "none")
                {
                    if (value == "currentColor")
                    {
                        canvas.strokeStyle = RGBA.white;
                    }
                    else
                    {
                        canvas.strokeStyle = RGBA.hex(value);
                    }

                }
                break;
            case "stroke-width":
                if (lineWidth == 0)
                {
                    canvas.lineWidth(parseLength(value, 1));
                }
                break;
            case "stroke-linecap":
                if (value == "round")
                    canvas.lineEnd(GraphicCanvas.LineEnd.round);
                else if (value == "square")
                    canvas.lineEnd(GraphicCanvas.LineEnd.square);
                else
                    canvas.lineEnd(GraphicCanvas.LineEnd.butt);
                break;
            case "stroke-linejoin":
                if (value == "round")
                    canvas.lineJoin(GraphicCanvas.LineJoin.round);
                else if (value == "bevel")
                    canvas.lineJoin(GraphicCanvas.LineJoin.bevel);
                else
                    canvas.lineJoin(GraphicCanvas.LineJoin.miter);
                break;
            case "fill":
                if (value != "none")
                {
                    canvas.fillStyle = value;
                }
                break;
            default:
                throw new Exception("Unsupported styles: " ~ key ~ " val: " ~ value);
                break;
        }
    }

    private void applyTransform(string transform)
    {
        //TODO transforms
        if (transform.startsWith("translate"))
        {
            // parse translate(x, y)
        }
        else if (transform.startsWith("scale"))
        {
            // parse scale(sx, sy)
        }
        else if (transform.startsWith("rotate"))
        {
            // parse rotate(angle, cx, cy)
        }
        else if (transform.startsWith("matrix"))
        {
            // parse matrix(a,b,c,d,e,f)
        }
    }

    private float parseLength(string value, float defaultValue = 0)
    {
        if (value.length == 0)
            return defaultValue;

        value = value.strip;

        if (value.endsWith("%"))
        {
            value = value[0 .. $ - 1];
            float percent = value.to!float();
            return percent / 100.0;
        }

        import std.string : endsWith;

        //TODO units
        string[] units = ["px", "pt", "em", "rem", "mm", "cm", "in"];
        foreach (unit; units)
        {
            if (value.endsWith(unit))
            {
                value = value[0 .. value.length - unit.length];
                break;
            }
        }

        return value.to!float();
    }

    private float[] parsePoints(string points)
    {
        float[] result;

        auto tokens = points.replace(",", " ").split();
        foreach (token; tokens)
        {
            token = token.strip();
            if (!token.empty)
            {
                try
                {
                    result ~= token.to!float();
                }
                catch (Exception)
                {
                    throw new Exception("Invalid point ", e);
                }
            }
        }

        return result;
    }
}
