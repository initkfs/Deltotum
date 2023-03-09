module deltotum.toolkit.graphics.colors.hsv;

import deltotum.toolkit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
struct HSV
{
    double hue = 0;
    double saturation = 0;
    double value = 0;

    static immutable struct HSVData
    {
        static enum
        {
            minHue = 0,
            maxHue = 360,
            minSaturation = 0,
            maxSaturation = 100,
            minValue = 0,
            maxValue = 100
        }
    }

    RGBA toRGBA() const pure @safe
    {
        if (value == 0)
        {
            return RGBA.black;
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
            h = (h == HSVData.maxHue) ? 0 : h / 60.0;
            i = cast(int) h;
            f = h - i;

            s *= 0.01;
            v *= 0.01;

            p = v * (1.0 - s);
            q = v * (1.0 - (s * f));
            t = v * (1.0 - (s * (1.0 - f)));

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
        auto toRGBAColor = (double value) => to!ubyte(round(value * RGBA.RGBAData.maxColor));

        RGBA result = RGBA(toRGBAColor(r), toRGBAColor(g), toRGBAColor(b));
        return result;
    }
}

unittest
{

    RGBA r0 = HSV(0, 0, 0).toRGBA;
    assert(r0 == RGBA.black);

    RGBA r02 = HSV(360, 100, 0).toRGBA;
    assert(r02 == RGBA.black);

    RGBA r03 = HSV(360, 0, 0).toRGBA;
    assert(r03 == RGBA.black);

    RGBA rFF0004 = HSV(360, 100, 100).toRGBA;
    assert(rFF0004.r == 255);
    assert(rFF0004.g == 0);
    assert(rFF0004.b == 0);

    RGBA r5e8339 = HSV(90.0, 56.4, 51.3).toRGBA;
    assert(r5e8339.r == 94);
    assert(r5e8339.g == 131);
    assert(r5e8339.b == 57);
}
