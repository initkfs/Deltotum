module deltotum.kit.graphics.colors.rgba;

import deltotum.kit.graphics.colors.palettes.html4_palette : Html4Palette;
import deltotum.kit.graphics.colors.hsv : HSV;

import std.regex;
import std.conv : to;

/**
 * Authors: initkfs
 */
struct RGBA
{
    //full names conflict with static color factories
    ubyte r;
    ubyte g;
    ubyte b;
    double a = 1;

    private
    {

        debug
        {
            //TODO placeholder
        }
        else
        {
            enum hexRegexRGB = ctRegex!(`^(0x|#)([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$`);
        }
    }

    static immutable struct RGBAData
    {
        static enum
        {
            minColor = 0,
            maxColor = 255,
            minAlpha = 0,
            maxAlpha = 1
        }
    }

    static
    {
        //TODO meta
        RGBA transparent() @nogc nothrow pure @safe
        {
            return RGBA(0, 0, 0, 0);
        }

        RGBA white() @nogc nothrow pure @safe
        {
            return RGBA(255, 255, 255);
        }

        RGBA black() @nogc nothrow pure @safe
        {
            return RGBA(0, 0, 0);
        }

        RGBA red() @nogc nothrow pure @safe
        {
            return RGBA(255, 0, 0);
        }

        RGBA green() @nogc nothrow pure @safe
        {
            return RGBA(0, 128, 0);
        }

        RGBA blue() @nogc nothrow pure @safe
        {
            return RGBA(0, 0, 255);
        }

        static RGBA gray(ubyte grayColor, double a = RGBAData.maxAlpha) @nogc nothrow pure @safe
        {
            return RGBA(grayColor, grayColor, grayColor, a);
        }
    }

    static RGBA rgba(ubyte r = RGBAData.maxColor, ubyte g = RGBAData.maxColor, ubyte b = RGBAData.maxColor, double a = RGBAData
            .maxAlpha) @nogc nothrow pure @safe
    {
        const RGBA color = {r, g, b, a};
        return color;
    }

    static RGBA web(string colorString, double a = RGBAData.maxAlpha) pure @safe
    {
        import std.traits : EnumMembers;
        import std.uni : sicmp;

        string webString = colorString;

        enum htmlColorsNames = __traits(allMembers, Html4Palette);
        enum string[htmlColorsNames.length] htmlColorsValues = [
                EnumMembers!Html4Palette
            ];

        foreach (i, colorName; htmlColorsNames)
        {
            if (sicmp(colorName, colorString) == 0)
            {
                webString = htmlColorsValues[i];
            }
        }

        debug
        {
            auto mustBeColor = webString;
        }
        else
        {
            auto mustBeMatchColor = matchFirst(webString, hexRegexRGB);
            if (mustBeMatchColor.empty)
            {
                throw new Exception("Wrong hex color representation: " ~ webString);
            }

            auto mustBeColor = mustBeMatchColor[0];
        }

        import std.algorithm.searching : startsWith;

        enum webPrefix = "#";
        enum hexPrefix = "0x";
        if (mustBeColor.startsWith(webPrefix))
        {
            mustBeColor = mustBeColor[1 .. $];
        }
        else if (mustBeColor.startsWith(hexPrefix))
        {
            mustBeColor = mustBeColor[2 .. $];
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

        RGBA c = {rValue, gValue, bValue, a};
        return c;
    }

    RGBA invert() @nogc nothrow pure @safe
    {
        return RGBA(RGBAData.maxColor - r, RGBAData.maxColor - g, RGBAData.maxColor - b, a);
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

    ubyte aNorm() const pure @safe
    {
        return to!ubyte(a * RGBAData.maxColor);
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
            ubyte byte4 = aNorm;
        }
        else version (BigEndian)
        {
            ubyte byte4 = b;
            ubyte byte3 = g;
            ubyte byte2 = r;
            ubyte byte1 = aNorm;
        }

        enum sizeOfBits = ubyte.sizeof * 8;
        uint rgba = (byte1 << sizeOfBits * 3) + (byte2 << sizeOfBits * 2) + (
            byte3 << sizeOfBits) + (byte4);
        return rgba;
    }

    double colorNorm(double colorValue) const pure @safe
    {
        return colorValue / RGBAData.maxColor;
    }

    double rNorm() const pure @safe
    {
        return colorNorm(r);
    }

    double gNorm() const pure @safe
    {
        return colorNorm(g);
    }

    double bNorm() const pure @safe
    {
        return colorNorm(b);
    }

    bool isMin() const pure @safe
    {
        enum minColor = RGBAData.minColor;
        return r == minColor && g == minColor && b == minColor && a == RGBAData.minColor;
    }

    bool isMax() const pure @safe
    {
        enum maxColor = RGBAData.maxColor;
        return r == maxColor && g == maxColor && b == maxColor && a == RGBAData.maxAlpha;
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

        import Math = deltotum.math;

        scope ubyte delegate(ubyte) pure @safe calc = (color) => cast(ubyte) Math.min(
            Math.round(color * factor), RGBAData.maxColor);

        r = calc(r);
        g = calc(g);
        b = calc(b);
    }

    void contrast(double factor) pure @safe
    {
        import std.conv : to;

        import Math = deltotum.math;

        double maxCoeffFactor = 259.0;
        double maxColor = RGBAData.maxColor;
        double halfColor = (maxColor + 1) / 2;

        const double correctFactor = (maxCoeffFactor * (factor + maxColor)) / (
            maxColor * (maxCoeffFactor - factor));

        scope ubyte delegate(ubyte) pure @safe calc = (color){
            const newValue = correctFactor * (color - halfColor) + halfColor;
            return cast(ubyte) Math.min(Math.abs(newValue), RGBA.RGBAData.maxColor);
        };

        r = calc(r);
        g = calc(g);
        b = calc(b);
    }

    void gamma(double value)  pure @safe
    {
        assert(value >= 0);
        import std.conv : to;

        import Math = deltotum.math;

        enum maxColor = RGBA.RGBAData.maxColor;
        double correctFactor = 1.0 / value;

        scope ubyte delegate(double) pure @safe calc = (colorNorm){
            const newValue = maxColor * (colorNorm ^^ correctFactor);
            return cast(ubyte) Math.min(newValue, maxColor);
        };

        r = calc(rNorm);
        g = calc(gNorm);
        b = calc(bNorm);
    }

    double distance(ref RGBA other) const pure @safe
    {
        import Math = deltotum.math;

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
            hue = fmod(hueStartAngle * ((newG - newB) / delta) + HSV.HSVData.maxHue, HSV
                    .HSVData.maxHue);
        }
        else if (isClose(cmax, newG))
        {
            hue = fmod(hueStartAngle * ((newB - newR) / delta) + 120, HSV.HSVData.maxHue);
        }
        else if (isClose(cmax, newB))
        {
            hue = fmod(hueStartAngle * ((newR - newG) / delta) + 240, HSV.HSVData.maxHue);
        }
        else
        {
            //TODO exception?
        }

        const double saturation = isClose(cmax, 0) ? 0 : (
            delta / cmax) * HSV.HSVData.maxSaturation;
        const double value = cmax * HSV.HSVData.maxValue;

        return HSV(hue, saturation, value);
    }

}

unittest
{
    enum colorMin = 0;
    RGBA rgba1 = RGBA.rgba(colorMin, colorMin, colorMin, colorMin);
    assert(rgba1.r == colorMin);
    assert(rgba1.g == colorMin);
    assert(rgba1.b == colorMin);
    assert(rgba1.a == colorMin);

    assert(rgba1.toString == "rgba(0,0,0,0.0)");
    assert(rgba1.toWebHex == "#000");

    enum colorMax = 255;
    enum alphaMax = 1;
    RGBA rgba2 = RGBA.rgba(colorMax, colorMax, colorMax, alphaMax);
    assert(rgba2.r == colorMax);
    assert(rgba2.g == colorMax);
    assert(rgba2.b == colorMax);
    assert(rgba2.a == alphaMax);

    assert(rgba2.toString == "rgba(255,255,255,1.0)");
    assert(rgba2.toWebHex == "#FFFFFF");
}

unittest
{
    RGBA colorWeb6Upper = RGBA.web("#FFFFFF", 0.5);
    assert(colorWeb6Upper.r == 255);
    assert(colorWeb6Upper.g == 255);
    assert(colorWeb6Upper.b == 255);
    assert(colorWeb6Upper.a == 0.5);

    RGBA colorWeb6 = RGBA.web("#ffffff", 0.5);
    assert(colorWeb6.r == 255);
    assert(colorWeb6.g == 255);
    assert(colorWeb6.b == 255);
    assert(colorWeb6.a == 0.5);

    RGBA colorWeb3 = RGBA.web("#ABC");
    assert(colorWeb3.r == 170);
    assert(colorWeb3.g == 187);
    assert(colorWeb3.b == 204);

    RGBA colorAqua = RGBA.web("#00ffff");
    assert(colorAqua.r == 0);
    assert(colorAqua.g == 255);
    assert(colorAqua.b == 255);

    RGBA colorAqua2 = RGBA.web("aqua");
    assert(colorAqua2.r == 0);
    assert(colorAqua2.g == 255);
    assert(colorAqua2.b == 255);

    RGBA white = RGBA.web("white");
    assert(white.r == 255);
    assert(white.g == 255);
    assert(white.b == 255);
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
