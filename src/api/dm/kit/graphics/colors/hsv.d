module api.dm.kit.graphics.colors.hsv;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsl : HSL;

import Math = api.math;

/**
 * Authors: initkfs
 */
struct HSV
{
    static enum : double
    {
        minHue = 0,
        maxHue = 360,
        minSaturation = 0,
        maxSaturation = 1,
        minValue = 0,
        maxValue = 1,
        minAlpha = 0,
        maxAlpha = 1
    }

    double hue = 0;
    double saturation = maxSaturation;
    double value = maxValue;
    double alpha = maxAlpha;

    import api.math.random : Random;

    static HSV random(Random rnd, double alpha = maxAlpha)
    {
        return HSV(
            rnd.between(minHue, maxHue),
            rnd.between(minSaturation, maxSaturation),
            rnd.between(minValue, maxValue),
            alpha
        );
    }

    RGBA toRGBA() const pure @safe
    {
        if (value == 0)
        {
            auto color = RGBA.black;
            color.a = alpha;
            return color;
        }

        double h = hue, s = saturation, v = value;
        double r = 0, g = 0, b = 0;
        double f = 0, p = 0, q = 0, t = 0;
        int i;

        if (saturation == 0)
        {
            r = v;
            g = v;
            b = v;
        }
        else
        {
            h = (h == maxHue) ? 0 : h / 60.0;
            i = cast(int) h;
            f = h - i;

            // s *= 0.01;
            // v *= 0.01;
            enum double maxValue = 1.0;

            p = v * (maxValue - s);
            q = v * (maxValue - (s * f));
            t = v * (maxValue - (s * (maxValue - f)));

            switch (i)
            {
                case 0:
                    r = v;
                    g = t;
                    b = p;
                    break;
                case 1:
                    r = q;
                    g = v;
                    b = p;
                    break;
                case 2:
                    r = p;
                    g = v;
                    b = t;
                    break;
                case 3:
                    r = p;
                    g = q;
                    b = v;
                    break;
                case 4:
                    r = t;
                    g = p;
                    b = v;
                    break;
                case 5:
                    r = v;
                    g = p;
                    b = q;
                    break;
                default:
                    r = v;
                    g = p;
                    b = q;
            }
        }

        import std.math.rounding : round;
        import std.conv : to;

        //TODO loss of precision and fractional values
        auto toRGBAColor = (double value) => to!ubyte(round(value * RGBA.maxColor));

        RGBA result = RGBA(toRGBAColor(r), toRGBAColor(g), toRGBAColor(b), alpha);
        return result;
    }

    /** 
     * https://stackoverflow.com/questions/3423214/convert-hsb-hsv-color-to-hsl
     */
    HSL toHSL() const @safe
    {
        double newHue = hue;
        double lightness = value - value * saturation / 2.0;

        double m = Math.min(lightness, 1 - lightness);
        double sat = m != 0 ? (value - lightness) / m : 0;

        return HSL(newHue, sat, lightness, alpha);
    }

    double setMaxHue() => hue = maxHue;
    double setMaxValue() => value = maxValue;
    double setMaxSaturation() => saturation = maxSaturation;

    double setMinHue() => hue = minHue;
    double setMinValue() => value = minValue;
    double setMinSaturation() => saturation = minSaturation;
}

unittest
{

    RGBA r0 = HSV(0, 0, 0).toRGBA;
    assert(r0 == RGBA.black);

    RGBA r02 = HSV(360, 1, 0).toRGBA;
    assert(r02 == RGBA.black);

    RGBA r03 = HSV(360, 0, 0).toRGBA;
    assert(r03 == RGBA.black);

    RGBA rFF0004 = HSV(360, 1, 1).toRGBA;
    assert(rFF0004.r == 255);
    assert(rFF0004.g == 0);
    assert(rFF0004.b == 0);

    RGBA r5e8339 = HSV(90.0, 0.564, 0.513).toRGBA;
    assert(r5e8339.r == 94);
    assert(r5e8339.g == 131);
    assert(r5e8339.b == 57);
}

unittest
{
    import std.math.operations : isClose;

    HSL hsl1 = HSV(60, 0.46, 0.78).toHSL;
    assert(isClose(hsl1.hue, 60));
    assert(isClose(hsl1.saturation, 0.4491, 0.001));
    assert(isClose(hsl1.lightness, 0.60, 0.001));
}
