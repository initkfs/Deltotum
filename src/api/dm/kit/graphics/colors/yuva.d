module api.dm.kit.graphics.colors.yuva;

import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */

struct YUVA
{
    ubyte y;
    ubyte u;
    ubyte v;
    float a = 0;

    RGBA toRGBA()
    {
        import Math = api.math;

        //R = Y + 1.140V
        //G = Y - 0.395U - 0.581V
        //B = Y + 2.032U

        const minValue = 0;
        const maxValue = ubyte.max;

        float unorm = u - 128.0f;
        float vnorm = v - 128.0f;
        float ynorm = y;

        float r = ynorm + 1.140f * vnorm;
        float g = ynorm - 0.395f * unorm - 0.581f * vnorm;
        float b = ynorm + 2.032f * unorm;

        return RGBA(
            cast(ubyte) Math.clamp(r, minValue, maxValue),
            cast(ubyte) Math.clamp(g, minValue, maxValue),
            cast(ubyte) Math.clamp(b, minValue, maxValue),
            a);
    }
}

unittest
{
    auto color = YUVA(41, 113, 122);
    auto rgba = color.toRGBA;
    assert(rgba.r == 34);
    assert(rgba.g == 50);
    assert(rgba.b == 10); //TODO - 14
}
