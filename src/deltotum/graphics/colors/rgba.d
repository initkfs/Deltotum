module deltotum.graphics.colors.rgba;

import std.regex;
import std.conv : to;

import std.stdio;

immutable string[string] html4Palette;
shared static this()
{
    html4Palette = [
        "aqua": "#00ffff",
        "black": "#000000",
        "blue": "#0000ff",
        "fuchsia": "#ff00ff",
        "gray": "#808080",
        "green": "#008000",
        "lime": "#00ff00",
        "maroon": "#800000",
        "navy": "#000080",
        "olive": "#808000",
        "purple": "#800080",
        "red": "#ff0000",
        "silver": "#c0c0c0",
        "teal": "#008080",
        "white": "#ffffff",
        "yellow": "#ffff00",
    ];
}

/**
 * Authors: initkfs
 */
struct RGBA
{
    //full names conflict with static color factories
    ubyte r;
    ubyte g;
    ubyte b;
    double alpha = 1;

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

        static RGBA gray(ubyte grayColor, double alpha = RGBAData.maxAlpha) @nogc nothrow pure @safe
        {
            return RGBA(grayColor, grayColor, grayColor, alpha);
        }
    }

    static RGBA rgba(ubyte r = RGBAData.maxColor, ubyte g = RGBAData.maxColor, ubyte b = RGBAData.maxColor, double a = RGBAData
            .maxAlpha) @nogc nothrow pure @safe
    {
        const RGBA color = {r, g, b, a};
        return color;
    }

    static RGBA web(string colorString, double alpha = RGBAData.maxAlpha) pure @safe
    {
        auto webString = colorString;
        if (auto paletteColorPtr = webString in html4Palette)
        {
            webString = *paletteColorPtr;
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

        RGBA c = {rValue, gValue, bValue, alpha};
        return c;
    }

    RGBA invert() @nogc nothrow pure @safe
    {
        return RGBA(RGBAData.maxColor - r, RGBAData.maxColor - g, RGBAData.maxColor - b, alpha);
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
        auto alphaValue = to!ubyte(start.alpha + (end.alpha - start.alpha) * factor);
        return RGBA(rValue, gValue, bValue, alphaValue);
    }

    ubyte alphaNorm() const pure @safe
    {
        return to!ubyte(alpha * RGBAData.maxColor);
    }

    string toWebHex() const pure @safe
    {
        import std.format : format;

        return format("#%X%X%X", r, g, b);
    }

    string toString() const pure @safe
    {
        import std.format : format;

        return format("rgba(%s,%s,%s,%.1f)", r, g, b, alpha);
    }

}

unittest
{
    enum colorMin = 0;
    RGBA rgba1 = RGBA.rgba(colorMin, colorMin, colorMin, colorMin);
    assert(rgba1.r == colorMin);
    assert(rgba1.g == colorMin);
    assert(rgba1.b == colorMin);
    assert(rgba1.alpha == colorMin);

    assert(rgba1.toString == "rgba(0,0,0,0.0)");
    assert(rgba1.toWebHex == "#000");

    enum colorMax = 255;
    enum alphaMax = 1;
    RGBA rgba2 = RGBA.rgba(colorMax, colorMax, colorMax, alphaMax);
    assert(rgba2.r == colorMax);
    assert(rgba2.g == colorMax);
    assert(rgba2.b == colorMax);
    assert(rgba2.alpha == alphaMax);

    assert(rgba2.toString == "rgba(255,255,255,1.0)");
    assert(rgba2.toWebHex == "#FFFFFF");
}

unittest
{
    RGBA colorWeb6Upper = RGBA.web("#FFFFFF", 0.5);
    assert(colorWeb6Upper.r == 255);
    assert(colorWeb6Upper.g == 255);
    assert(colorWeb6Upper.b == 255);
    assert(colorWeb6Upper.alpha == 0.5);

    RGBA colorWeb6 = RGBA.web("#ffffff", 0.5);
    assert(colorWeb6.r == 255);
    assert(colorWeb6.g == 255);
    assert(colorWeb6.b == 255);
    assert(colorWeb6.alpha == 0.5);

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
