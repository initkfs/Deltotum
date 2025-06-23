module api.dm.kit.graphics.colors.hsla;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsva : HSVA;

import Math = api.math;

/**
 * Authors: initkfs
 */
struct HSLA
{
    static enum : double
    {
        minHue = 0,
        maxHue = 360,
        minSaturation = 0,
        maxSaturation = 1,
        minLightness = 0,
        maxLightness = 1,
        minAlpha = 0,
        maxAlpha = 1
    }

    double h = 0;
    double s = maxSaturation;
    double l = maxLightness;
    double a = maxAlpha;

    import api.math.random : Random;

    static HSLA random(Random rnd, double newAlpha = maxAlpha)
    {
        return HSLA(
            rnd.between(minHue, maxHue),
            rnd.between(minSaturation, maxSaturation),
            rnd.between(minLightness, maxLightness),
            newAlpha
        );
    }

    /** 
     * https://stackoverflow.com/questions/2353211/hsl-to-rgb-color-conversion
     */
    RGBA toRGBA()
    {
        const double hueNorm = h / maxHue;

        double r = 0;
        double g = 0;
        double b = 0;

        if (s == 0)
        {
            r = l;
            g = l;
            b = l;
        }
        else
        {
            double convertHue(double p, double q, double t)
            {
                if (t < 0)
                {
                    t += 1;
                }

                if (t > 1)
                {
                    t -= 1;
                }

                if (t < (1 / 6.0))
                {
                    return p + (q - p) * 6 * t;
                }

                if (t < (1 / 2.0))
                {
                    return q;
                }

                if (t < (2 / 3.0))
                {
                    return p + (q - p) * ((2 / 3.0) - t) * 6;
                }

                return p;
            }

            const double q = (l < 0.5) ? (l * (1 + s)) : (
                l + s - l * s);
            const double p = 2 * l - q;

            r = convertHue(p, q, hueNorm + 1 / 3.0);
            g = convertHue(p, q, hueNorm);
            b = convertHue(p, q, hueNorm - 1 / 3.0);
        }

        import Math = api.math;

        const newR = cast(ubyte) Math.round(r * RGBA.maxColor);
        const newG = cast(ubyte) Math.round(g * RGBA.maxColor);
        const newB = cast(ubyte) Math.round(b * RGBA.maxColor);

        return RGBA(newR, newG, newB, a);
    }

    /** 
     * https://stackoverflow.com/questions/3423214/convert-hsb-hsv-color-to-hsl
     */
    HSVA toHSVA() const @safe
    {
        double newHue = h;
        double newValue = s * Math.min(l, 1 - l) + l;

        double newSaturation = newValue != 0 ? (2.0 - 2 * l / newValue) : 0;

        return HSVA(newHue, newSaturation, newValue, a);
    }

    double setMaxHue() => h = maxHue;
    double setMaxLightness() => l = maxLightness;
    double setMaxSaturation() => s = maxSaturation;

    double setMinHue() => h = minHue;
    double setMinLightness() => l = minLightness;
    double setMinSaturation() => s = minSaturation;
}

unittest
{
    import std.math.operations : isClose;

    auto rgba1 = HSLA(123, 0.43, 0.56).toRGBA;

    assert(rgba1.r == 95);
    assert(rgba1.g == 191);
    assert(rgba1.b == 99);
    assert(isClose(rgba1.a, 1));

}

unittest
{
    import std.math.operations : isClose;

    auto hsv1 = HSLA(123, 0.43, 0.56).toHSVA;

    assert(isClose(hsv1.h, 123));
    assert(isClose(hsv1.s, 0.5050, 0.001));
    assert(isClose(hsv1.v, 0.7492, 0.001));
    assert(isClose(hsv1.a, 1));
}
