module api.dm.kit.graphics.colors.hsl;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsv : HSV;

import Math = api.math;

/**
 * Authors: initkfs
 */
struct HSL
{
    static enum : double
    {
        minHue = 0,
        maxHue = 360,
        minSaturation = 0,
        maxSaturation = 1,
        minLightness = 0,
        maxLightness = 1
    }

    double hue = 0;
    double saturation = maxSaturation;
    double lightness = maxLightness;
    //TODO alpha?
    //double alpha = 0;

    /** 
     * https://stackoverflow.com/questions/2353211/hsl-to-rgb-color-conversion
     */
    RGBA toRGBA()
    {
        const double hueNorm = hue / maxHue;

        double r = 0;
        double g = 0;
        double b = 0;

        if (saturation == 0)
        {
            r = lightness;
            g = lightness;
            b = lightness;
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

            const double q = (lightness < 0.5) ? (lightness * (1 + saturation)) : (lightness + saturation - lightness * saturation);
            const double p = 2 * lightness - q;

            r = convertHue(p, q, hueNorm + 1 / 3.0);
            g = convertHue(p, q, hueNorm);
            b = convertHue(p, q, hueNorm - 1 / 3.0);
        }
        
        import Math = api.math;

        const newR = cast(ubyte) Math.round(r * RGBA.maxColor);
        const newG = cast(ubyte) Math.round(g * RGBA.maxColor);
        const newB = cast(ubyte) Math.round(b * RGBA.maxColor);

        return RGBA(newR, newG, newB);
    }

    /** 
     * https://stackoverflow.com/questions/3423214/convert-hsb-hsv-color-to-hsl
     */
    HSV toHSV() const @safe {
        double newHue = hue;
        double newValue = saturation *Math.min(lightness,1-lightness)+lightness;

        double newSaturation = newValue != 0 ? (2.0 - 2 * lightness / newValue) : 0;

        return HSV(newHue, newSaturation, newValue);
    }

    double setMaxHue() => hue = maxHue;
    double setMaxLightness() => lightness = maxLightness;
    double setMaxSaturation() => saturation = maxSaturation;

    double setMinHue() => hue = minHue;
    double setMinLightness() => lightness = minLightness;
    double setMinSaturation() => saturation = minSaturation;
}

unittest
{
    import std.math.operations: isClose;
    auto rgba1 = HSL(123, 0.43, 0.56).toRGBA;

    assert(rgba1.r == 95);
    assert(rgba1.g == 191);
    assert(rgba1.b == 99);

}

unittest
{
    import std.math.operations: isClose;
    auto hsv1 = HSL(123, 0.43, 0.56).toHSV;

    assert(isClose(hsv1.hue, 123));
    assert(isClose(hsv1.saturation, 0.5050, 0.001));
    assert(isClose(hsv1.value, 0.7492, 0.001));
}
