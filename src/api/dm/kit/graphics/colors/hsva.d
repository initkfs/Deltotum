module api.dm.kit.graphics.colors.hsva;

import Color = api.dm.kit.graphics.colors.color;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsla : HSLA;

import Math = api.math;

/**
 * Authors: initkfs
 */
struct HSVA
{
    static enum : double
    {
        minHue = 0,
        maxHue = 360,
        minSaturation = 0,
        maxSaturation = 1,
        minValue = 0,
        maxValue = 1,
        minAlpha = Color.minAlpha,
        maxAlpha = Color.maxAlpha
    }

    double h = 0;
    double s = maxSaturation;
    double v = maxValue;
    double a= maxAlpha;

    import api.math.random : Random;

    static HSVA random(Random rnd, double alpha = maxAlpha)
    {
        return HSVA(
            rnd.between(minHue, maxHue),
            rnd.between(minSaturation, maxSaturation),
            rnd.between(minValue, maxValue),
            alpha
        );
    }

    RGBA toRGBA() const pure @safe
    {
        if (v == 0)
        {
            auto color = RGBA.black;
            color.a = a;
            return color;
        }

        double hue = h, sat = s, value = v;
        double r = 0, g = 0, b = 0;
        double f = 0, p = 0, q = 0, t = 0;
        int i;

        if (s == 0)
        {
            r = value;
            g = value;
            b = value;
        }
        else
        {
            hue = (hue == maxHue) ? 0 : hue / 60.0;
            i = cast(int) hue;
            f = hue - i;

            // s *= 0.01;
            // v *= 0.01;
            enum double maxValue = 1.0;

            p = value * (maxValue - sat);
            q = value * (maxValue - (sat * f));
            t = value * (maxValue - (sat * (maxValue - f)));

            switch (i)
            {
                case 0:
                    r = value;
                    g = t;
                    b = p;
                    break;
                case 1:
                    r = q;
                    g = value;
                    b = p;
                    break;
                case 2:
                    r = p;
                    g = value;
                    b = t;
                    break;
                case 3:
                    r = p;
                    g = q;
                    b = value;
                    break;
                case 4:
                    r = t;
                    g = p;
                    b = value;
                    break;
                case 5:
                    r = value;
                    g = p;
                    b = q;
                    break;
                default:
                    r = value;
                    g = p;
                    b = q;
            }
        }

        import std.math.rounding : round;
        import std.conv : to;

        //TODO loss of precision and fractional values
        ubyte toRGBAColor(double value) => to!ubyte(round(value * RGBA.maxColor));

        RGBA result = RGBA(toRGBAColor(r), toRGBAColor(g), toRGBAColor(b), a);
        return result;
    }

    /** 
     * https://stackoverflow.com/questions/3423214/convert-hsb-hsv-color-to-hsl
     */
    HSLA toHSLA() const @safe
    {
        double newHue = h;
        double lightness = v - v * s / 2.0;

        double m = Math.min(lightness, 1 - lightness);
        double sat = m != 0 ? (v - lightness) / m : 0;

        return HSLA(newHue, sat, lightness, a);
    }

    double setMaxHue() => h = maxHue;
    double setMaxValue() => v = maxValue;
    double setMaxSaturation() => s = maxSaturation;

    double setMinHue() => h = minHue;
    double setMinValue() => v = minValue;
    double setMinSaturation() => s = minSaturation;
}

unittest
{

    RGBA r0 = HSVA(0, 0, 0).toRGBA;
    assert(r0 == RGBA.black);

    RGBA r02 = HSVA(360, 1, 0).toRGBA;
    assert(r02 == RGBA.black);

    RGBA r03 = HSVA(360, 0, 0).toRGBA;
    assert(r03 == RGBA.black);

    RGBA rFF0004 = HSVA(360, 1, 1).toRGBA;
    assert(rFF0004.r == 255);
    assert(rFF0004.g == 0);
    assert(rFF0004.b == 0);

    RGBA r5e8339 = HSVA(90.0, 0.564, 0.513).toRGBA;
    assert(r5e8339.r == 94);
    assert(r5e8339.g == 131);
    assert(r5e8339.b == 57);
}

unittest
{
    import std.math.operations : isClose;

    HSLA hsl1 = HSVA(60, 0.46, 0.78).toHSLA;
    assert(isClose(hsl1.h, 60));
    assert(isClose(hsl1.s, 0.4491, 0.001));
    assert(isClose(hsl1.l, 0.60, 0.001));
}
