module api.dm.kit.graphics.colors.rgba;

import api.dm.kit.graphics.colors.hsva : HSVA;
import api.dm.kit.graphics.colors.hsla : HSLA;

import std.regex;
import std.conv : to;
import std.traits : EnumMembers;

private
{
    debug
    {
    }
    else
    {
        enum hexRegexCt = ctRegex!(`^(0x|#)([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$`);
    }
}

struct RGBAb
{
    ubyte r;
    ubyte g;
    ubyte b;
    ubyte a;
}

/**
 * Authors: initkfs
 */
struct RGBA
{
    ubyte r;
    ubyte g;
    ubyte b;
    double a = 1;

    enum : ubyte
    {
        minColor = 0,
        maxColor = 255,
    }

    enum : double
    {
        minAlpha = 0,
        maxAlpha = 1
    }

    static RGBA web(string colorString, double a = maxAlpha) pure @safe
    {
        if (colorString.length == 0)
        {
            throw new Exception("Hex color string must not be empty");
        }

        string mustBeColor;

        import std.ascii : isAlpha;

        if (!colorString[0].isAlpha)
        {
            mustBeColor = colorString;
        }
        else
        {
            throw new Exception("Invalid web color name: " ~ colorString);
        }

        debug
        {
        }
        else
        {
            if (!__ctfe)
            {
                //matchAll impure
                auto mustBeMatchColor = matchFirst(mustBeColor, hexRegexCt);
                if (mustBeMatchColor.empty)
                {
                    throw new Exception(
                        "Invalid hex color format: string does not match hexadecimal pattern: " ~ mustBeColor);
                }
                mustBeColor = mustBeMatchColor[0];
            }
        }

        import std.algorithm.searching : startsWith;

        enum webPrefix = "#";
        enum hexPrefix = "0x";
        if (mustBeColor.startsWith(webPrefix) || mustBeColor.startsWith(hexPrefix))
        {
            mustBeColor = mustBeColor[webPrefix.length .. $];
        }

        enum fullColorFormLength = 6;
        enum shortColorFormLength = 3;

        const formColorLength = mustBeColor.length;
        ubyte rValue, gValue, bValue;
        enum hexBase = 16;
        if (formColorLength == fullColorFormLength)
        {
            rValue = to!ubyte(mustBeColor[0 .. 2], hexBase);
            gValue = to!ubyte(mustBeColor[2 .. 4], hexBase);
            bValue = to!ubyte(mustBeColor[4 .. 6], hexBase);
        }
        else if (formColorLength == shortColorFormLength)
        {
            import std.array : replicate;

            enum replicateCount = 2;
            rValue = to!ubyte(replicate(mustBeColor[0 .. 1], replicateCount), hexBase);
            gValue = to!ubyte(replicate(mustBeColor[1 .. 2], replicateCount), hexBase);
            bValue = to!ubyte(replicate(mustBeColor[2 .. 3], replicateCount), hexBase);
        }
        else
        {
            throw new Exception("Invalid hexadecimal RGBA value: " ~ mustBeColor);
        }

        RGBA c = {rValue, gValue, bValue, a};
        return c;
    }

    import api.math.random : Random;

    static RGBA random(double alpha = maxAlpha)
    {
        auto rnd = new Random;
        return random(rnd, alpha);
    }

    static RGBA random(Random rnd, double alpha = maxAlpha)
    {
        const min = RGBA.minColor;
        const max = RGBA.maxColor;
        RGBA newColor = {
            r: rnd.between!ubyte(min, max),
            g: rnd.between!ubyte(min, max),
            b: rnd.between!ubyte(min, max),
            a: alpha
        };
        return newColor;
    }

    RGBA invert() nothrow pure @safe
    {
        return RGBA(maxColor - r, maxColor - g, maxColor - b, a);
    }

    RGBA interpolate(RGBA start, RGBA end, double factor = 0.5) pure @safe
    {
        if (factor <= 0)
        {
            return start;
        }

        if (factor >= 1.0)
        {
            return end;
        }

        auto rValue = to!ubyte(start.r + (end.r - start.r) * factor);
        auto gValue = to!ubyte(start.g + (end.g - start.g) * factor);
        auto bValue = to!ubyte(start.b + (end.b - start.b) * factor);
        auto alphaValue = to!ubyte(start.a + (end.a - start.a) * factor);
        return RGBA(rValue, gValue, bValue, alphaValue);
    }

    string toWebHex() const pure @safe
    {
        import std.format : format;

        return format("#%02X%02X%02X", r, g, b);
    }

    string toString() const pure @safe
    {
        import std.format : format;

        return format("rgba(%s,%s,%s,%.1f)", r, g, b, a);
    }

    static RGBA fromUint(uint value) pure @safe
    {
        ubyte max = ubyte.max;
        const sizeOfBits = ubyte.sizeof * 8;

        ubyte byte1 = (value >> sizeOfBits * 3) & max;
        ubyte byte2 = (value >> sizeOfBits * 2) & max;
        ubyte byte3 = (value >> sizeOfBits) & max;
        ubyte byte4 = value & max;

        version (LittleEndian)
        {
            ubyte r = byte1;
            ubyte g = byte2;
            ubyte b = byte3;
            ubyte a = byte4;
        }
        else version (BigEndian)
        {
            ubyte r = byte4;
            ubyte g = byte3;
            ubyte b = byte2;
            ubyte a = byte1;
        }

        return RGBA(r, g, b, a / max);
    }

    uint toUint() const pure @safe
    {
        version (LittleEndian)
        {
            ubyte byte1 = r;
            ubyte byte2 = g;
            ubyte byte3 = b;
            ubyte byte4 = aByte;
        }
        else version (BigEndian)
        {
            ubyte byte4 = b;
            ubyte byte3 = g;
            ubyte byte2 = r;
            ubyte byte1 = aByte;
        }

        enum sizeOfBits = ubyte.sizeof * 8;
        uint rgba = (byte1 << sizeOfBits * 3) + (byte2 << sizeOfBits * 2) + (
            byte3 << sizeOfBits) + (byte4);
        return rgba;
    }

    double colorNorm(double colorValue) const pure @safe
    {
        return colorValue / maxColor;
    }

    double rNorm() const pure @safe => colorNorm(r);
    double gNorm() const pure @safe => colorNorm(g);
    double bNorm() const pure @safe => colorNorm(b);
    ubyte aByte() const pure @safe => to!ubyte(a * maxColor);

    static double fromAByte(ubyte value) pure @safe => (cast(double) value) / maxColor;

    bool isMin() const pure @safe
    {
        return r == minColor && g == minColor && b == minColor && a == minColor;
    }

    bool isMax() const pure @safe
    {
        return r == maxColor && g == maxColor && b == maxColor && a == maxAlpha;
    }

    uint sumColor() const pure @safe
    {
        return r + g + b;
    }

    double brightness() const pure @safe
    {
        double result = (r + b + g) / 3.0;
        return result;
    }

    void brightness(double factor) pure @safe
    {
        //or convert to HSVA, and scale V.
        assert(factor > 0);
        import std.conv : to;

        import Math = api.dm.math;

        pure @safe ubyte calc(ubyte color)
        {
            return cast(ubyte) Math.min(Math.round(color * factor), maxColor);
        }

        r = calc(r);
        g = calc(g);
        b = calc(b);
    }

    void contrast(double factor) pure @safe
    {
        import std.conv : to;

        import Math = api.dm.math;

        double maxCoeffFactor = 259.0;
        double maxColor = maxColor;
        double halfColor = (maxColor + 1) / 2;

        const double correctFactor = (maxCoeffFactor * (factor + maxColor)) / (
            maxColor * (maxCoeffFactor - factor));

        pure @safe ubyte calc(ubyte color)
        {
            const newValue = correctFactor * (color - halfColor) + halfColor;
            return cast(ubyte) Math.min(Math.abs(newValue), RGBA.maxColor);
        }

        r = calc(r);
        g = calc(g);
        b = calc(b);
    }

    void gamma(double value) pure @safe
    {
        assert(value >= 0);
        import std.conv : to;

        import Math = api.dm.math;

        enum maxColor = RGBA.maxColor;
        double correctFactor = 1.0 / value;

        pure @safe ubyte calc(double colorNorm)
        {
            const newValue = maxColor * (colorNorm ^^ correctFactor);
            return cast(ubyte) Math.min(newValue, maxColor);
        }

        r = calc(rNorm);
        g = calc(gNorm);
        b = calc(bNorm);
    }

    double distance(ref RGBA other) const pure @safe
    {
        import Math = api.dm.math;

        double distanceSum = ((r - other.r) ^^ 2) + (
            (g - other.g) ^^ 2) + ((b - other.b) ^^ 2);
        double distance = Math.sqrt(distanceSum);
        return distance;
    }

    ubyte setMaxR() => r = maxColor;
    ubyte setMaxG() => g = maxColor;
    ubyte setMaxB() => b = maxColor;
    double setMaxA() => a = maxAlpha;

    ubyte setMinR() => r = minColor;
    ubyte setMinG() => g = minColor;
    ubyte setMinB() => b = minColor;
    double setMinA() => a = minAlpha;

    HSVA toHSVA() const @safe
    {
        const double newR = colorNorm(r);
        const double newG = colorNorm(g);
        const double newB = colorNorm(b);

        import std.math.operations : isClose;
        import std.algorithm.comparison : min, max;
        import std.math.remainder : fmod;

        const double cmax = max(newR, max(newG, newB));
        const double cmin = min(newR, min(newG, newB));
        const double delta = cmax - cmin;

        enum hueStartAngle = 60;

        double hue = -1;

        if (isClose(cmax, cmin))
        {
            hue = 0;
        }
        else if (isClose(cmax, newR))
        {
            hue = fmod(hueStartAngle * ((newG - newB) / delta) + HSVA.maxHue, HSVA
                    .maxHue);
        }
        else if (isClose(cmax, newG))
        {
            hue = fmod(hueStartAngle * ((newB - newR) / delta) + 120, HSVA.maxHue);
        }
        else if (isClose(cmax, newB))
        {
            hue = fmod(hueStartAngle * ((newR - newG) / delta) + 240, HSVA.maxHue);
        }
        else
        {
            //TODO exception?
        }

        const double saturation = isClose(cmax, 0) ? 0 : (
            delta / cmax) * HSVA.maxSaturation;
        const double value = cmax * HSVA.maxValue;

        return HSVA(hue, saturation, value, a);
    }

    /** 
     * https://stackoverflow.com/questions/2353211/hsl-to-rgb-color-conversion
     */
    HSLA toHSLA() const @safe
    {
        import Math = api.math;

        double rn = rNorm;
        double rg = gNorm;
        double rb = bNorm;

        const double max = Math.max(rn, rg, rb);
        const double min = Math.min(rn, rg, rb);

        double h = 0;
        double s = 0;
        double l = (max + min) / 2.0;

        if (max == min)
        {
            h = 0;
            s = 0;

            return HSLA(h, s, l, a);
        }

        const double dist = max - min;

        s = l > 0.5 ? (dist / (2 - max - min)) : (dist / (max + min));

        import std.math.operations : isClose;

        if (isClose(max, rn))
        {
            h = (rg - rb) / dist + (rg < rb ? 6 : 0);
        }
        else if (isClose(max, rg))
        {
            h = (rb - rn) / dist + 2;
        }
        else if (isClose(max, rb))
        {
            h = (rn - rg) / dist + 4;
        }

        h /= 6;
        h = h * 360.0;

        return HSLA(h, s, l, a);
    }

    RGBAb toRGBAb() => RGBAb(r, g, b, aByte);

    float[3] toRGBArray() => [r, g, b];

    static
    {
        RGBA transparent() nothrow pure @safe => RGBA(0, 0, 0, 0);

        RGBA aliceblue() nothrow pure @safe => RGBA(240, 248, 255);
        RGBA antiquewhite() nothrow pure @safe => RGBA(250, 235, 215);
        RGBA aqua() nothrow pure @safe => RGBA(0, 255, 255);
        RGBA aquamarine() nothrow pure @safe => RGBA(127, 255, 212);
        RGBA azure() nothrow pure @safe => RGBA(240, 255, 255);
        RGBA beige() nothrow pure @safe => RGBA(245, 245, 220);
        RGBA bisque() nothrow pure @safe => RGBA(255, 228, 196);
        RGBA black() nothrow pure @safe => RGBA(0, 0, 0);
        RGBA blanchedalmond() nothrow pure @safe => RGBA(255, 235, 205);
        RGBA blue() nothrow pure @safe => RGBA(0, 0, 255);
        RGBA blueviolet() nothrow pure @safe => RGBA(138, 43, 226);
        RGBA brown() nothrow pure @safe => RGBA(165, 42, 42);
        RGBA burlywood() nothrow pure @safe => RGBA(222, 184, 135);
        RGBA cadetblue() nothrow pure @safe => RGBA(95, 158, 160);
        RGBA chartreuse() nothrow pure @safe => RGBA(127, 255, 0);
        RGBA chocolate() nothrow pure @safe => RGBA(210, 105, 30);
        RGBA coral() nothrow pure @safe => RGBA(255, 127, 80);
        RGBA cornflowerblue() nothrow pure @safe => RGBA(100, 149, 237);
        RGBA cornsilk() nothrow pure @safe => RGBA(255, 248, 220);
        RGBA crimson() nothrow pure @safe => RGBA(220, 20, 60);
        RGBA cyan() nothrow pure @safe => RGBA(0, 255, 255);
        RGBA darkblue() nothrow pure @safe => RGBA(0, 0, 139);
        RGBA darkcyan() nothrow pure @safe => RGBA(0, 139, 139);
        RGBA darkgoldenrod() nothrow pure @safe => RGBA(184, 134, 11);
        RGBA darkgray() nothrow pure @safe => RGBA(169, 169, 169);
        RGBA darkgreen() nothrow pure @safe => RGBA(0, 100, 0);
        RGBA darkgrey() nothrow pure @safe => RGBA(169, 169, 169);
        RGBA darkkhaki() nothrow pure @safe => RGBA(189, 183, 107);
        RGBA darkmagenta() nothrow pure @safe => RGBA(139, 0, 139);
        RGBA darkolivegreen() nothrow pure @safe => RGBA(85, 107, 47);
        RGBA darkorange() nothrow pure @safe => RGBA(255, 140, 0);
        RGBA darkorchid() nothrow pure @safe => RGBA(153, 50, 204);
        RGBA darkred() nothrow pure @safe => RGBA(139, 0, 0);
        RGBA darksalmon() nothrow pure @safe => RGBA(233, 150, 122);
        RGBA darkseagreen() nothrow pure @safe => RGBA(143, 188, 143);
        RGBA darkslateblue() nothrow pure @safe => RGBA(72, 61, 139);
        RGBA darkslategray() nothrow pure @safe => RGBA(47, 79, 79);
        RGBA darkslategrey() nothrow pure @safe => RGBA(47, 79, 79);
        RGBA darkturquoise() nothrow pure @safe => RGBA(0, 206, 209);
        RGBA darkviolet() nothrow pure @safe => RGBA(148, 0, 211);
        RGBA deeppink() nothrow pure @safe => RGBA(255, 20, 147);
        RGBA deepskyblue() nothrow pure @safe => RGBA(0, 191, 255);
        RGBA dimgray() nothrow pure @safe => RGBA(105, 105, 105);
        RGBA dimgrey() nothrow pure @safe => RGBA(105, 105, 105);
        RGBA dodgerblue() nothrow pure @safe => RGBA(30, 144, 255);
        RGBA firebrick() nothrow pure @safe => RGBA(178, 34, 34);
        RGBA floralwhite() nothrow pure @safe => RGBA(255, 250, 240);
        RGBA forestgreen() nothrow pure @safe => RGBA(34, 139, 34);
        RGBA fuchsia() nothrow pure @safe => RGBA(255, 0, 255);
        RGBA gainsboro() nothrow pure @safe => RGBA(220, 220, 220);
        RGBA ghostwhite() nothrow pure @safe => RGBA(248, 248, 255);
        RGBA gold() nothrow pure @safe => RGBA(255, 215, 0);
        RGBA goldenrod() nothrow pure @safe => RGBA(218, 165, 32);
        RGBA gray() nothrow pure @safe => RGBA(128, 128, 128);
        RGBA green() nothrow pure @safe => RGBA(0, 128, 0);
        RGBA greenyellow() nothrow pure @safe => RGBA(173, 255, 47);
        RGBA grey() nothrow pure @safe => RGBA(128, 128, 128);
        RGBA honeydew() nothrow pure @safe => RGBA(240, 255, 240);
        RGBA hotpink() nothrow pure @safe => RGBA(255, 105, 180);
        RGBA indianred() nothrow pure @safe => RGBA(205, 92, 92);
        RGBA indigo() nothrow pure @safe => RGBA(75, 0, 130);
        RGBA ivory() nothrow pure @safe => RGBA(255, 255, 240);
        RGBA khaki() nothrow pure @safe => RGBA(240, 230, 140);
        RGBA lavender() nothrow pure @safe => RGBA(230, 230, 250);
        RGBA lavenderblush() nothrow pure @safe => RGBA(255, 240, 245);
        RGBA lawngreen() nothrow pure @safe => RGBA(124, 252, 0);
        RGBA lemonchiffon() nothrow pure @safe => RGBA(255, 250, 205);
        RGBA lightblue() nothrow pure @safe => RGBA(173, 216, 230);
        RGBA lightcoral() nothrow pure @safe => RGBA(240, 128, 128);
        RGBA lightcyan() nothrow pure @safe => RGBA(224, 255, 255);
        RGBA lightgoldenrodyellow() nothrow pure @safe => RGBA(250, 250, 210);
        RGBA lightgray() nothrow pure @safe => RGBA(211, 211, 211);
        RGBA lightgreen() nothrow pure @safe => RGBA(144, 238, 144);
        RGBA lightgrey() nothrow pure @safe => RGBA(211, 211, 211);
        RGBA lightpink() nothrow pure @safe => RGBA(255, 182, 193);
        RGBA lightsalmon() nothrow pure @safe => RGBA(255, 160, 122);
        RGBA lightseagreen() nothrow pure @safe => RGBA(32, 178, 170);
        RGBA lightskyblue() nothrow pure @safe => RGBA(135, 206, 250);
        RGBA lightslategray() nothrow pure @safe => RGBA(119, 136, 153);
        RGBA lightslategrey() nothrow pure @safe => RGBA(119, 136, 153);
        RGBA lightsteelblue() nothrow pure @safe => RGBA(176, 196, 222);
        RGBA lightyellow() nothrow pure @safe => RGBA(255, 255, 224);
        RGBA lime() nothrow pure @safe => RGBA(0, 255, 0);
        RGBA limegreen() nothrow pure @safe => RGBA(50, 205, 50);
        RGBA linen() nothrow pure @safe => RGBA(250, 240, 230);
        RGBA magenta() nothrow pure @safe => RGBA(255, 0, 255);
        RGBA maroon() nothrow pure @safe => RGBA(128, 0, 0);
        RGBA mediumaquamarine() nothrow pure @safe => RGBA(102, 205, 170);
        RGBA mediumblue() nothrow pure @safe => RGBA(0, 0, 205);
        RGBA mediumorchid() nothrow pure @safe => RGBA(186, 85, 211);
        RGBA mediumpurple() nothrow pure @safe => RGBA(147, 112, 219);
        RGBA mediumseagreen() nothrow pure @safe => RGBA(60, 179, 113);
        RGBA mediumslateblue() nothrow pure @safe => RGBA(123, 104, 238);
        RGBA mediumspringgreen() nothrow pure @safe => RGBA(0, 250, 154);
        RGBA mediumturquoise() nothrow pure @safe => RGBA(72, 209, 204);
        RGBA mediumvioletred() nothrow pure @safe => RGBA(199, 21, 133);
        RGBA midnightblue() nothrow pure @safe => RGBA(25, 25, 112);
        RGBA mintcream() nothrow pure @safe => RGBA(245, 255, 250);
        RGBA mistyrose() nothrow pure @safe => RGBA(255, 228, 225);
        RGBA moccasin() nothrow pure @safe => RGBA(255, 228, 181);
        RGBA navajowhite() nothrow pure @safe => RGBA(255, 222, 173);
        RGBA navy() nothrow pure @safe => RGBA(0, 0, 128);
        RGBA oldlace() nothrow pure @safe => RGBA(253, 245, 230);
        RGBA olive() nothrow pure @safe => RGBA(128, 128, 0);
        RGBA olivedrab() nothrow pure @safe => RGBA(107, 142, 35);
        RGBA orange() nothrow pure @safe => RGBA(255, 165, 0);
        RGBA orangered() nothrow pure @safe => RGBA(255, 69, 0);
        RGBA orchid() nothrow pure @safe => RGBA(218, 112, 214);
        RGBA palegoldenrod() nothrow pure @safe => RGBA(238, 232, 170);
        RGBA palegreen() nothrow pure @safe => RGBA(152, 251, 152);
        RGBA paleturquoise() nothrow pure @safe => RGBA(175, 238, 238);
        RGBA palevioletred() nothrow pure @safe => RGBA(219, 112, 147);
        RGBA papayawhip() nothrow pure @safe => RGBA(255, 239, 213);
        RGBA peachpuff() nothrow pure @safe => RGBA(255, 218, 185);
        RGBA peru() nothrow pure @safe => RGBA(205, 133, 63);
        RGBA pink() nothrow pure @safe => RGBA(255, 192, 203);
        RGBA plum() nothrow pure @safe => RGBA(221, 160, 221);
        RGBA powderblue() nothrow pure @safe => RGBA(176, 224, 230);
        RGBA purple() nothrow pure @safe => RGBA(128, 0, 128);
        RGBA red() nothrow pure @safe => RGBA(255, 0, 0);
        RGBA rosybrown() nothrow pure @safe => RGBA(188, 143, 143);
        RGBA royalblue() nothrow pure @safe => RGBA(65, 105, 225);
        RGBA saddlebrown() nothrow pure @safe => RGBA(139, 69, 19);
        RGBA salmon() nothrow pure @safe => RGBA(250, 128, 114);
        RGBA sandybrown() nothrow pure @safe => RGBA(244, 164, 96);
        RGBA seagreen() nothrow pure @safe => RGBA(46, 139, 87);
        RGBA seashell() nothrow pure @safe => RGBA(255, 245, 238);
        RGBA sienna() nothrow pure @safe => RGBA(160, 82, 45);
        RGBA silver() nothrow pure @safe => RGBA(192, 192, 192);
        RGBA skyblue() nothrow pure @safe => RGBA(135, 206, 235);
        RGBA slateblue() nothrow pure @safe => RGBA(106, 90, 205);
        RGBA slategray() nothrow pure @safe => RGBA(112, 128, 144);
        RGBA slategrey() nothrow pure @safe => RGBA(112, 128, 144);
        RGBA snow() nothrow pure @safe => RGBA(255, 250, 250);
        RGBA springgreen() nothrow pure @safe => RGBA(0, 255, 127);
        RGBA steelblue() nothrow pure @safe => RGBA(70, 130, 180);
        RGBA tan() nothrow pure @safe => RGBA(210, 180, 140);
        RGBA teal() nothrow pure @safe => RGBA(0, 128, 128);
        RGBA thistle() nothrow pure @safe => RGBA(216, 191, 216);
        RGBA tomato() nothrow pure @safe => RGBA(255, 99, 71);
        RGBA turquoise() nothrow pure @safe => RGBA(64, 224, 208);
        RGBA violet() nothrow pure @safe => RGBA(238, 130, 238);
        RGBA wheat() nothrow pure @safe => RGBA(245, 222, 179);
        RGBA white() nothrow pure @safe => RGBA(255, 255, 255);
        RGBA whitesmoke() nothrow pure @safe => RGBA(245, 245, 245);
        RGBA yellow() nothrow pure @safe => RGBA(255, 255, 0);
        RGBA yellowgreen() nothrow pure @safe => RGBA(154, 205, 50);
    }
}

unittest
{
    enum colorMin = 0;
    RGBA rgba1 = {colorMin, colorMin, colorMin, colorMin};
    assert(rgba1.r == colorMin);
    assert(rgba1.g == colorMin);
    assert(rgba1.b == colorMin);
    assert(rgba1.a == colorMin);

    assert(rgba1.toString == "rgba(0,0,0,0.0)");
    assert(rgba1.toWebHex == "#000000");

    enum colorMax = 255;
    enum alphaMax = 1;
    RGBA rgba2 = {colorMax, colorMax, colorMax, alphaMax};
    assert(rgba2.r == colorMax);
    assert(rgba2.g == colorMax);
    assert(rgba2.b == colorMax);
    assert(rgba2.a == alphaMax);

    assert(rgba2.toString == "rgba(255,255,255,1.0)");
    assert(rgba2.toWebHex == "#FFFFFF");
}

unittest
{
    immutable colorWeb6Upper = RGBA.web("#FFFFFF", 0.5);
    assert(colorWeb6Upper.r == 255);
    assert(colorWeb6Upper.g == 255);
    assert(colorWeb6Upper.b == 255);
    assert(colorWeb6Upper.a == 0.5);

    immutable colorWeb6 = RGBA.web("#ffffff", 0.5);
    assert(colorWeb6.r == 255);
    assert(colorWeb6.g == 255);
    assert(colorWeb6.b == 255);
    assert(colorWeb6.a == 0.5);

    immutable colorWeb3 = RGBA.web("#ABC");
    assert(colorWeb3.r == 170);
    assert(colorWeb3.g == 187);
    assert(colorWeb3.b == 204);

    immutable colorAqua = RGBA.web("#00ffff");
    assert(colorAqua.r == 0);
    assert(colorAqua.g == 255);
    assert(colorAqua.b == 255);

    // const colorAqua2 = RGBA.web("aqua");
    // assert(colorAqua2.r == 0);
    // assert(colorAqua2.g == 255);
    // assert(colorAqua2.b == 255);

    // shared white = RGBA.web("white");
    // assert(white.r == 255);
    // assert(white.g == 255);
    // assert(white.b == 255);
}

unittest
{
    RGBA r = RGBA.red;
    assert(r == RGBA.web("#ff0000"));
    RGBA g = RGBA.green;
    assert(g == RGBA.web("#008000"));
}

unittest
{
    import std.math.operations : isClose;
    import std.math.rounding : round;

    HSVA hsv0 = RGBA.black.toHSVA;

    assert(hsv0.h == 0);
    assert(hsv0.s == 0);
    assert(hsv0.v == 0);

    HSVA hsv255 = RGBA.white.toHSVA;
    assert(hsv255.h == 0);
    assert(hsv255.s == 0);
    assert(hsv255.v == 1);

    HSVA hsv1 = RGBA(34, 50, 16).toHSVA;
    assert(isClose(hsv1.h, 88.24, 0.0001));
    assert(isClose(hsv1.s, 0.68, 0.0001));
    assert(isClose(hsv1.v, 0.196, 0.001));
}

unittest
{
    import std.math.operations : isClose;
    import std.math.rounding : round;

    HSLA hsl1 = RGBA.black.toHSLA;

    assert(hsl1.h == 0);
    assert(hsl1.s == 0);
    assert(hsl1.l == 0);

    HSLA hsl2 = RGBA(123, 16, 24).toHSLA;

    assert(isClose(hsl2.h, 355.5, 0.1));
    assert(isClose(hsl2.s, 0.7698, 0.01));
    assert(isClose(hsl2.l, 0.2725, 0.01));
}

unittest
{
    const color1 = RGBA(17, 54, 76, 1.0);
    uint color1Uint = color1.toUint;

    assert(color1Uint == 0x11364cff);

    const color1FromUint = RGBA.fromUint(color1Uint);
    assert(color1FromUint.r == 17);
    assert(color1FromUint.g == 54);
    assert(color1FromUint.b == 76);
    assert(color1FromUint.a == 1.0);

    const color0 = RGBA(0, 0, 0, 0);
    assert(color0.toUint == 0);

    const color0FromUint = RGBA.fromUint(0);
    assert(color0FromUint.r == 0);
    assert(color0FromUint.g == 0);
    assert(color0FromUint.b == 0);
    assert(color0FromUint.a == 0);
}
