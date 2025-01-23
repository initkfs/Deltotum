module api.dm.kit.graphics.colors.lcha;

import Color = api.dm.kit.graphics.colors.color;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsva : HSVA;

import Math = api.math;

import std.conv : to;

ubyte rgb255(double v) => (v < 255 ? (v > 0 ? v.to!ubyte : 0) : 255);
double b1(double v) => (v > 0.0031308 ? (v ^^ (1 / 2.4) * 269.025 - 14.025) : v * 3294.6);
double b2(double v) => (v > 0.2068965 ? (v ^^ 3.0) : (v - 4 / 29.0) * (108 / 841.0));
double a1(double v) => (v > 10.314724 ? (((v + 14.025) / 269.025) ^^ 2.4) : v / 3294.6);
double a2(double v) => (v > 0.0088564 ? (v ^^ (1 / 3.0)) : (v / (108 / 841.0) + 4 / 29.0));

/**
 * Authors: initkfs
 * https://stackoverflow.com/questions/7530627/hcl-color-to-rgb-and-backward
 */
struct LCHA
{
    double l = 0;
    double c = 0;
    double h = 0;
    double a = Color.maxAlpha;

    static enum : double
    {
        minHue = 0,
        maxHue = 360,
        minChroma = 0,
        maxChroma = 1,
        minLightness = 0,
        maxLightness = 1,
        minAlpha = Color.minAlpha,
        maxAlpha = Color.maxAlpha
    }

    RGBA toRGBA()
    {
        double lightness = l * 100;
        double chroma = c * 100;
        double hue = h;

        const y = b2((lightness = (lightness + 16) / 116));
        const x = b2(lightness + (chroma / 500) * Math.cos((hue *= Math.PI / 180)));
        const z = b2(lightness - (chroma / 200) * Math.sin(hue));
        
        const r = rgb255(b1(x * 3.021973625 - y * 1.617392459 - z * 0.404875592));
        const g = rgb255(b1(x * -0.943766287 + y * 1.916279586 + z * 0.027607165));
        const b = rgb255(b1(x * 0.069407491 - y * 0.22898585 + z * 1.159737864));
        return RGBA(r, g, b);
    }

    void fromRGBA(RGBA rgba)
    {
        auto r = rgba.r.to!double;
        auto g = rgba.g.to!double;
        auto b = rgba.b.to!double;

        double y = a2((r = a1(r)) * 0.222488403 + (g = a1(g)) * 0.716873169 + (b = a1(b)) * 0.06060791);
        double l = 500 * (a2(r * 0.452247074 + g * 0.399439023 + b * 0.148375274) - y);
        double q = 200 * (y - a2(r * 0.016863605 + g * 0.117638439 + b * 0.865350722));
        double h = Math.atan2(q, l) * (180.0 / Math.PI);

        this.h = h < 0 ? (h + 360) : h;
        this.c = (Math.sqrt(l * l + q * q)) / 100.0;
        this.l = (116 * y - 16) / 100.0;
    }

}

unittest
{
    import std.math.operations : isClose;

    LCHA lch = LCHA(0.17, 0.56, 128);
    RGBA rgb = lch.toRGBA;
    assert(rgb.r == 0);
    assert(rgb.g == 52);
    assert(rgb.b == 0);

    LCHA lch2 = LCHA(0.87, 0.23, 360);
    RGBA rgb2 = lch2.toRGBA;
    assert(rgb2.r == 255);
    assert(rgb2.g == 202);
    assert(rgb2.b == 218);

    LCHA lch3 = LCHA(0.11, 0.78, 0);
    RGBA rgb3 = lch3.toRGBA;
    assert(rgb3.r == 108);
    assert(rgb3.g == 0);
    assert(rgb3.b == 33);
}

unittest
{
    import std.math.operations : isClose;

    double eps = 0.001;

    RGBA rgb1 = RGBA(0, 52, 0);
    LCHA lch1;
    lch1.fromRGBA(rgb1);
    assert(isClose(lch1.l, 0.1774, eps));
    assert(isClose(lch1.c, 0.35416, eps));
    assert(isClose(lch1.h, 136.67, eps));
}
