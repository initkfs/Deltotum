module api.dm.kit.graphics.colors.processings.blends;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.numericals.interp : blerp;

import api.math.geom2.rect2 : Rect2d;

import Math = api.math;

/**
 * Authors: initkfs
 */
//TODO other modes
enum BlendMode
{
    normal,
    multiply,
    divide,
    screen,
    overlay,
}

RGBA[][] blend(RGBA[][] colors, RGBA maskColor, BlendMode mode = BlendMode.normal)
{
    assert(colors.length > 0);
    assert(colors[0].length > 0);

    size_t colorHeight = colors.length;
    size_t colorWidth = colors[0].length;

    //TODO mask from RGBA[][]
    RGBA[][] buffer = new RGBA[][](colorHeight, colorWidth);
    blend(colors, maskColor, buffer, mode);
    return buffer;
}

void blend(RGBA[][] colors, RGBA maskColor, RGBA[][] buffer, BlendMode mode = BlendMode.normal)
{
    assert(colors.length > 0);
    assert(colors[0].length > 0);

    scope ubyte delegate(double) colorCalc = (value) {
        const result = cast(ubyte) Math.clamp(Math.round(value), RGBA.minColor, RGBA
                .maxColor);
        return result;
    };

    foreach (y, colorRow; colors)
    {
        foreach (x, ref color; colorRow)
        {
            double r = 0, g = 0, b = 0, a = 0;

            //TODO remove duplication
            final switch (mode) with (BlendMode)
            {
                case normal:
                    r = maskColor.r;
                    g = maskColor.g;
                    b = maskColor.b;
                    a = maskColor.a;
                    break;
                case multiply:
                    r = blendMultiply(color.r, maskColor.r);
                    g = blendMultiply(color.g, maskColor.g);
                    b = blendMultiply(color.b, maskColor.b);
                    a = blendMultiply(color.a, maskColor.a);
                    break;
                case divide:
                    r = blendDivide(color.r, maskColor.r);
                    g = blendDivide(color.g, maskColor.g);
                    b = blendDivide(color.b, maskColor.b);
                    a = blendDivide(color.a, maskColor.a);
                    break;
                case screen:
                    r = blendScreen(color.r, maskColor.r);
                    g = blendScreen(color.g, maskColor.g);
                    b = blendScreen(color.b, maskColor.b);
                    a = blendScreen(color.a, maskColor.a);
                    break;
                case overlay:
                    r = blendOverlay(color.r, maskColor.r);
                    g = blendOverlay(color.g, maskColor.g);
                    b = blendOverlay(color.b, maskColor.b);
                    a = blendOverlay(color.a, maskColor.a);
                    break;
            }

            auto colorPtr = &buffer[y][x];

            colorPtr.r = colorCalc(r);
            colorPtr.g = colorCalc(g);
            colorPtr.b = colorCalc(b);
            colorPtr.a = Math.clamp(a, RGBA.minAlpha, RGBA.maxAlpha);
        }
    }
}

double blendMultiply(double color, double colorMask)
{
    double factor = 1 / 255.0;
    return color * colorMask * factor;
}

double blendDivide(double color, double colorMask)
{
    return (color * (RGBA.maxColor + 1)) / (colorMask + 1);
}

double blendScreen(double color, double colorMask)
{
    const max = RGBA.maxColor;
    return max - (((max - colorMask) * (max - color)) / max);
}

double blendOverlay(double color, double colorMask)
{
    const max = RGBA.maxColor;
    const coeff1 = (color / max);
    const coeff2 = (2 * colorMask) / max;
    return coeff1 * (color + coeff2 * (max - 1));
}