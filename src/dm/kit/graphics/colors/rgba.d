module dm.kit.graphics.colors.rgba;

import dm.kit.graphics.colors.palettes.extended_palette : ExtendedPalette;
import dm.kit.graphics.colors.hsv : HSV;

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

    immutable webColorsNames = __traits(allMembers, ExtendedPalette);
    immutable string[webColorsNames.length] webColorsValues = [
        EnumMembers!ExtendedPalette
    ];
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

    static enum
    {
        minColor = 0,
        maxColor = 255,
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
        import std.uni : sicmp;

        if (!colorString[0].isAlpha)
        {
            mustBeColor = colorString;
        }
        else
        {
            foreach (i, colorName; webColorsNames)
            {
                //TODO check cmp\icmp perfomance
                if (sicmp(colorName, colorString) == 0)
                {
                    mustBeColor = webColorsValues[i];
                    break;
                }
            }

            if (mustBeColor.length == 0)
            {
                throw new Exception("Invalid web color name: " ~ colorString);
            }
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

    RGBA invert() @nogc nothrow pure @safe
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

        return format("#%X%X%X", r, g, b);
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
        //or convert to HSV, and scale V.
        assert(factor > 0);
        import std.conv : to;

        import Math = dm.math;

        scope ubyte delegate(ubyte) pure @safe calc = (color) => cast(ubyte) Math.min(
            Math.round(color * factor), maxColor);

        r = calc(r);
        g = calc(g);
        b = calc(b);
    }

    void contrast(double factor) pure @safe
    {
        import std.conv : to;

        import Math = dm.math;

        double maxCoeffFactor = 259.0;
        double maxColor = maxColor;
        double halfColor = (maxColor + 1) / 2;

        const double correctFactor = (maxCoeffFactor * (factor + maxColor)) / (
            maxColor * (maxCoeffFactor - factor));

        scope ubyte delegate(ubyte) pure @safe calc = (color) {
            const newValue = correctFactor * (color - halfColor) + halfColor;
            return cast(ubyte) Math.min(Math.abs(newValue), RGBA.maxColor);
        };

        r = calc(r);
        g = calc(g);
        b = calc(b);
    }

    void gamma(double value) pure @safe
    {
        assert(value >= 0);
        import std.conv : to;

        import Math = dm.math;

        enum maxColor = RGBA.maxColor;
        double correctFactor = 1.0 / value;

        scope ubyte delegate(double) pure @safe calc = (colorNorm) {
            const newValue = maxColor * (colorNorm ^^ correctFactor);
            return cast(ubyte) Math.min(newValue, maxColor);
        };

        r = calc(rNorm);
        g = calc(gNorm);
        b = calc(bNorm);
    }

    double distance(ref RGBA other) const pure @safe
    {
        import Math = dm.math;

        double distanceSum = ((r - other.r) ^^ 2) + (
            (g - other.g) ^^ 2) + ((b - other.b) ^^ 2);
        double distance = Math.sqrt(distanceSum);
        return distance;
    }

    HSV toHSV() const @safe
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
            hue = fmod(hueStartAngle * ((newG - newB) / delta) + HSV.maxHue, HSV
                    .maxHue);
        }
        else if (isClose(cmax, newG))
        {
            hue = fmod(hueStartAngle * ((newB - newR) / delta) + 120, HSV.maxHue);
        }
        else if (isClose(cmax, newB))
        {
            hue = fmod(hueStartAngle * ((newR - newG) / delta) + 240, HSV.maxHue);
        }
        else
        {
            //TODO exception?
        }

        const double saturation = isClose(cmax, 0) ? 0 : (
            delta / cmax) * HSV.maxSaturation;
        const double value = cmax * HSV.maxValue;

        return HSV(hue, saturation, value);
    }

    static
    {
        // static foreach (i, colorName; webColorsNames)
        // {
        //     mixin(
        //         "typeof(this) ", colorName, "() @nogc nothrow pure @safe { ",
        //         "return ", "typeof(this)", ".web(\"", webColorsValues[i], "\");",
        //         "}"
        //     );
        // }

        RGBA transparent() @nogc nothrow pure @safe => RGBA(0, 0, 0, 0);

        RGBA aliceblue() @nogc nothrow pure @safe => RGBA(240, 248, 255);
        RGBA antiquewhite() @nogc nothrow pure @safe => RGBA(250, 235, 215);
        RGBA aqua() @nogc nothrow pure @safe => RGBA(0, 255, 255);
        RGBA aquamarine() @nogc nothrow pure @safe => RGBA(127, 255, 212);
        RGBA azure() @nogc nothrow pure @safe => RGBA(240, 255, 255);
        RGBA beige() @nogc nothrow pure @safe => RGBA(245, 245, 220);
        RGBA bisque() @nogc nothrow pure @safe => RGBA(255, 228, 196);
        RGBA black() @nogc nothrow pure @safe => RGBA(0, 0, 0);
        RGBA blanchedalmond() @nogc nothrow pure @safe => RGBA(255, 235, 205);
        RGBA blue() @nogc nothrow pure @safe => RGBA(0, 0, 255);
        RGBA blueviolet() @nogc nothrow pure @safe => RGBA(138, 43, 226);
        RGBA brown() @nogc nothrow pure @safe => RGBA(165, 42, 42);
        RGBA burlywood() @nogc nothrow pure @safe => RGBA(222, 184, 135);
        RGBA cadetblue() @nogc nothrow pure @safe => RGBA(95, 158, 160);
        RGBA chartreuse() @nogc nothrow pure @safe => RGBA(127, 255, 0);
        RGBA chocolate() @nogc nothrow pure @safe => RGBA(210, 105, 30);
        RGBA coral() @nogc nothrow pure @safe => RGBA(255, 127, 80);
        RGBA cornflowerblue() @nogc nothrow pure @safe => RGBA(100, 149, 237);
        RGBA cornsilk() @nogc nothrow pure @safe => RGBA(255, 248, 220);
        RGBA crimson() @nogc nothrow pure @safe => RGBA(220, 20, 60);
        RGBA cyan() @nogc nothrow pure @safe => RGBA(0, 255, 255);
        RGBA darkblue() @nogc nothrow pure @safe => RGBA(0, 0, 139);
        RGBA darkcyan() @nogc nothrow pure @safe => RGBA(0, 139, 139);
        RGBA darkgoldenrod() @nogc nothrow pure @safe => RGBA(184, 134, 11);
        RGBA darkgray() @nogc nothrow pure @safe => RGBA(169, 169, 169);
        RGBA darkgreen() @nogc nothrow pure @safe => RGBA(0, 100, 0);
        RGBA darkgrey() @nogc nothrow pure @safe => RGBA(169, 169, 169);
        RGBA darkkhaki() @nogc nothrow pure @safe => RGBA(189, 183, 107);
        RGBA darkmagenta() @nogc nothrow pure @safe => RGBA(139, 0, 139);
        RGBA darkolivegreen() @nogc nothrow pure @safe => RGBA(85, 107, 47);
        RGBA darkorange() @nogc nothrow pure @safe => RGBA(255, 140, 0);
        RGBA darkorchid() @nogc nothrow pure @safe => RGBA(153, 50, 204);
        RGBA darkred() @nogc nothrow pure @safe => RGBA(139, 0, 0);
        RGBA darksalmon() @nogc nothrow pure @safe => RGBA(233, 150, 122);
        RGBA darkseagreen() @nogc nothrow pure @safe => RGBA(143, 188, 143);
        RGBA darkslateblue() @nogc nothrow pure @safe => RGBA(72, 61, 139);
        RGBA darkslategray() @nogc nothrow pure @safe => RGBA(47, 79, 79);
        RGBA darkslategrey() @nogc nothrow pure @safe => RGBA(47, 79, 79);
        RGBA darkturquoise() @nogc nothrow pure @safe => RGBA(0, 206, 209);
        RGBA darkviolet() @nogc nothrow pure @safe => RGBA(148, 0, 211);
        RGBA deeppink() @nogc nothrow pure @safe => RGBA(255, 20, 147);
        RGBA deepskyblue() @nogc nothrow pure @safe => RGBA(0, 191, 255);
        RGBA dimgray() @nogc nothrow pure @safe => RGBA(105, 105, 105);
        RGBA dimgrey() @nogc nothrow pure @safe => RGBA(105, 105, 105);
        RGBA dodgerblue() @nogc nothrow pure @safe => RGBA(30, 144, 255);
        RGBA firebrick() @nogc nothrow pure @safe => RGBA(178, 34, 34);
        RGBA floralwhite() @nogc nothrow pure @safe => RGBA(255, 250, 240);
        RGBA forestgreen() @nogc nothrow pure @safe => RGBA(34, 139, 34);
        RGBA fuchsia() @nogc nothrow pure @safe => RGBA(255, 0, 255);
        RGBA gainsboro() @nogc nothrow pure @safe => RGBA(220, 220, 220);
        RGBA ghostwhite() @nogc nothrow pure @safe => RGBA(248, 248, 255);
        RGBA gold() @nogc nothrow pure @safe => RGBA(255, 215, 0);
        RGBA goldenrod() @nogc nothrow pure @safe => RGBA(218, 165, 32);
        RGBA gray() @nogc nothrow pure @safe => RGBA(128, 128, 128);
        RGBA green() @nogc nothrow pure @safe => RGBA(0, 128, 0);
        RGBA greenyellow() @nogc nothrow pure @safe => RGBA(173, 255, 47);
        RGBA grey() @nogc nothrow pure @safe => RGBA(128, 128, 128);
        RGBA honeydew() @nogc nothrow pure @safe => RGBA(240, 255, 240);
        RGBA hotpink() @nogc nothrow pure @safe => RGBA(255, 105, 180);
        RGBA indianred() @nogc nothrow pure @safe => RGBA(205, 92, 92);
        RGBA indigo() @nogc nothrow pure @safe => RGBA(75, 0, 130);
        RGBA ivory() @nogc nothrow pure @safe => RGBA(255, 255, 240);
        RGBA khaki() @nogc nothrow pure @safe => RGBA(240, 230, 140);
        RGBA lavender() @nogc nothrow pure @safe => RGBA(230, 230, 250);
        RGBA lavenderblush() @nogc nothrow pure @safe => RGBA(255, 240, 245);
        RGBA lawngreen() @nogc nothrow pure @safe => RGBA(124, 252, 0);
        RGBA lemonchiffon() @nogc nothrow pure @safe => RGBA(255, 250, 205);
        RGBA lightblue() @nogc nothrow pure @safe => RGBA(173, 216, 230);
        RGBA lightcoral() @nogc nothrow pure @safe => RGBA(240, 128, 128);
        RGBA lightcyan() @nogc nothrow pure @safe => RGBA(224, 255, 255);
        RGBA lightgoldenrodyellow() @nogc nothrow pure @safe => RGBA(250, 250, 210);
        RGBA lightgray() @nogc nothrow pure @safe => RGBA(211, 211, 211);
        RGBA lightgreen() @nogc nothrow pure @safe => RGBA(144, 238, 144);
        RGBA lightgrey() @nogc nothrow pure @safe => RGBA(211, 211, 211);
        RGBA lightpink() @nogc nothrow pure @safe => RGBA(255, 182, 193);
        RGBA lightsalmon() @nogc nothrow pure @safe => RGBA(255, 160, 122);
        RGBA lightseagreen() @nogc nothrow pure @safe => RGBA(32, 178, 170);
        RGBA lightskyblue() @nogc nothrow pure @safe => RGBA(135, 206, 250);
        RGBA lightslategray() @nogc nothrow pure @safe => RGBA(119, 136, 153);
        RGBA lightslategrey() @nogc nothrow pure @safe => RGBA(119, 136, 153);
        RGBA lightsteelblue() @nogc nothrow pure @safe => RGBA(176, 196, 222);
        RGBA lightyellow() @nogc nothrow pure @safe => RGBA(255, 255, 224);
        RGBA lime() @nogc nothrow pure @safe => RGBA(0, 255, 0);
        RGBA limegreen() @nogc nothrow pure @safe => RGBA(50, 205, 50);
        RGBA linen() @nogc nothrow pure @safe => RGBA(250, 240, 230);
        RGBA magenta() @nogc nothrow pure @safe => RGBA(255, 0, 255);
        RGBA maroon() @nogc nothrow pure @safe => RGBA(128, 0, 0);
        RGBA mediumaquamarine() @nogc nothrow pure @safe => RGBA(102, 205, 170);
        RGBA mediumblue() @nogc nothrow pure @safe => RGBA(0, 0, 205);
        RGBA mediumorchid() @nogc nothrow pure @safe => RGBA(186, 85, 211);
        RGBA mediumpurple() @nogc nothrow pure @safe => RGBA(147, 112, 219);
        RGBA mediumseagreen() @nogc nothrow pure @safe => RGBA(60, 179, 113);
        RGBA mediumslateblue() @nogc nothrow pure @safe => RGBA(123, 104, 238);
        RGBA mediumspringgreen() @nogc nothrow pure @safe => RGBA(0, 250, 154);
        RGBA mediumturquoise() @nogc nothrow pure @safe => RGBA(72, 209, 204);
        RGBA mediumvioletred() @nogc nothrow pure @safe => RGBA(199, 21, 133);
        RGBA midnightblue() @nogc nothrow pure @safe => RGBA(25, 25, 112);
        RGBA mintcream() @nogc nothrow pure @safe => RGBA(245, 255, 250);
        RGBA mistyrose() @nogc nothrow pure @safe => RGBA(255, 228, 225);
        RGBA moccasin() @nogc nothrow pure @safe => RGBA(255, 228, 181);
        RGBA navajowhite() @nogc nothrow pure @safe => RGBA(255, 222, 173);
        RGBA navy() @nogc nothrow pure @safe => RGBA(0, 0, 128);
        RGBA oldlace() @nogc nothrow pure @safe => RGBA(253, 245, 230);
        RGBA olive() @nogc nothrow pure @safe => RGBA(128, 128, 0);
        RGBA olivedrab() @nogc nothrow pure @safe => RGBA(107, 142, 35);
        RGBA orange() @nogc nothrow pure @safe => RGBA(255, 165, 0);
        RGBA orangered() @nogc nothrow pure @safe => RGBA(255, 69, 0);
        RGBA orchid() @nogc nothrow pure @safe => RGBA(218, 112, 214);
        RGBA palegoldenrod() @nogc nothrow pure @safe => RGBA(238, 232, 170);
        RGBA palegreen() @nogc nothrow pure @safe => RGBA(152, 251, 152);
        RGBA paleturquoise() @nogc nothrow pure @safe => RGBA(175, 238, 238);
        RGBA palevioletred() @nogc nothrow pure @safe => RGBA(219, 112, 147);
        RGBA papayawhip() @nogc nothrow pure @safe => RGBA(255, 239, 213);
        RGBA peachpuff() @nogc nothrow pure @safe => RGBA(255, 218, 185);
        RGBA peru() @nogc nothrow pure @safe => RGBA(205, 133, 63);
        RGBA pink() @nogc nothrow pure @safe => RGBA(255, 192, 203);
        RGBA plum() @nogc nothrow pure @safe => RGBA(221, 160, 221);
        RGBA powderblue() @nogc nothrow pure @safe => RGBA(176, 224, 230);
        RGBA purple() @nogc nothrow pure @safe => RGBA(128, 0, 128);
        RGBA red() @nogc nothrow pure @safe => RGBA(255, 0, 0);
        RGBA rosybrown() @nogc nothrow pure @safe => RGBA(188, 143, 143);
        RGBA royalblue() @nogc nothrow pure @safe => RGBA(65, 105, 225);
        RGBA saddlebrown() @nogc nothrow pure @safe => RGBA(139, 69, 19);
        RGBA salmon() @nogc nothrow pure @safe => RGBA(250, 128, 114);
        RGBA sandybrown() @nogc nothrow pure @safe => RGBA(244, 164, 96);
        RGBA seagreen() @nogc nothrow pure @safe => RGBA(46, 139, 87);
        RGBA seashell() @nogc nothrow pure @safe => RGBA(255, 245, 238);
        RGBA sienna() @nogc nothrow pure @safe => RGBA(160, 82, 45);
        RGBA silver() @nogc nothrow pure @safe => RGBA(192, 192, 192);
        RGBA skyblue() @nogc nothrow pure @safe => RGBA(135, 206, 235);
        RGBA slateblue() @nogc nothrow pure @safe => RGBA(106, 90, 205);
        RGBA slategray() @nogc nothrow pure @safe => RGBA(112, 128, 144);
        RGBA slategrey() @nogc nothrow pure @safe => RGBA(112, 128, 144);
        RGBA snow() @nogc nothrow pure @safe => RGBA(255, 250, 250);
        RGBA springgreen() @nogc nothrow pure @safe => RGBA(0, 255, 127);
        RGBA steelblue() @nogc nothrow pure @safe => RGBA(70, 130, 180);
        RGBA tan() @nogc nothrow pure @safe => RGBA(210, 180, 140);
        RGBA teal() @nogc nothrow pure @safe => RGBA(0, 128, 128);
        RGBA thistle() @nogc nothrow pure @safe => RGBA(216, 191, 216);
        RGBA tomato() @nogc nothrow pure @safe => RGBA(255, 99, 71);
        RGBA turquoise() @nogc nothrow pure @safe => RGBA(64, 224, 208);
        RGBA violet() @nogc nothrow pure @safe => RGBA(238, 130, 238);
        RGBA wheat() @nogc nothrow pure @safe => RGBA(245, 222, 179);
        RGBA white() @nogc nothrow pure @safe => RGBA(255, 255, 255);
        RGBA whitesmoke() @nogc nothrow pure @safe => RGBA(245, 245, 245);
        RGBA yellow() @nogc nothrow pure @safe => RGBA(255, 255, 0);
        RGBA yellowgreen() @nogc nothrow pure @safe => RGBA(154, 205, 50);
    }
}

unittest
{
    enum colorMin = 0;
    RGBA rgba1 = { colorMin, colorMin, colorMin, colorMin };
    assert(rgba1.r == colorMin);
    assert(rgba1.g == colorMin);
    assert(rgba1.b == colorMin);
    assert(rgba1.a == colorMin);

    assert(rgba1.toString == "rgba(0,0,0,0.0)");
    assert(rgba1.toWebHex == "#000");

    enum colorMax = 255;
    enum alphaMax = 1;
    RGBA rgba2 = { colorMax, colorMax, colorMax, alphaMax};
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

    const colorAqua2 = RGBA.web("aqua");
    assert(colorAqua2.r == 0);
    assert(colorAqua2.g == 255);
    assert(colorAqua2.b == 255);

    shared white = RGBA.web("white");
    assert(white.r == 255);
    assert(white.g == 255);
    assert(white.b == 255);
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

    HSV hsv0 = RGBA.black.toHSV;

    assert(hsv0.hue == 0);
    assert(hsv0.saturation == 0);
    assert(hsv0.value == 0);

    HSV hsv255 = RGBA.white.toHSV;
    assert(hsv255.hue == 0);
    assert(hsv255.saturation == 0);
    assert(hsv255.value == 100);

    HSV hsv1 = RGBA(34, 50, 16).toHSV;
    assert(isClose(hsv1.hue, 88.24, 0.0001));
    assert(isClose(hsv1.saturation, 68));
    assert(isClose(hsv1.value, 19.6, 0.001));
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
