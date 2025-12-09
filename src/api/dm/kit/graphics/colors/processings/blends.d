module api.dm.kit.graphics.colors.processings.blends;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.numericals.interp : blerp;

import api.math.geom2.rect2 : Rect2f;

import Math = api.math;

/**
 * Authors: initkfs
 */
enum BlendMode
{
    normal,
    multiply,
    divide,
    screen,
    overlay,
    additive,
    subtract,
    darken,
    lighten,
    softlight,
    dodge,
    difference,
    exclusion,
    burn,
    onecolor,
    hue,
    saturation,
    luminocity,
    pinlight
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

    // ubyte colorCalc(float value) {
    //     const result = cast(ubyte) Math.clamp(Math.round(value), RGBA.minColor, RGBA
    //             .maxColor);
    //     return result;
    // }

    foreach (y, colorRow; colors)
    {
        foreach (x, ref color; colorRow)
        {
            RGBA newColor;
            //TODO remove duplication
            final switch (mode) with (BlendMode)
            {
                case normal:
                    newColor = blendNormal(color, maskColor);
                    break;
                case multiply:
                    newColor = blendMultiply(color, maskColor);
                    break;
                case divide:
                    newColor = blendDivide(color, maskColor);
                    break;
                case screen:
                    newColor = blendScreen(color, maskColor);
                    break;
                case overlay:
                    newColor = blendOverlay(color, maskColor);
                    break;
                case additive:
                    newColor = blendAdditive(color, maskColor);
                    break;
                case subtract:
                    newColor = blendSubtract(color, maskColor);
                    break;
                case darken:
                    newColor = blendDarken(color, maskColor);
                    break;
                case lighten:
                    newColor = blendLighten(color, maskColor);
                    break;
                case softlight:
                    newColor = blendSoftLight(color, maskColor);
                    break;
                case dodge:
                    newColor = blendrDodge(color, maskColor);
                    break;
                case difference:
                    newColor = blendDifference(color, maskColor);
                    break;
                case exclusion:
                    newColor = blendExclusion(color, maskColor);
                    break;
                case burn:
                    newColor = blendBurn(color, maskColor);
                    break;
                case onecolor:
                    newColor = blendOneColor(color, maskColor);
                    break;
                case hue:
                    newColor = blendHue(color, maskColor);
                    break;
                case saturation:
                    newColor = blendSaturation(color, maskColor);
                    break;
                case luminocity:
                    newColor = blendLuminosity(color, maskColor);
                    break;
                case pinlight:
                    newColor = blendPinlight(color, maskColor);
                    break;
            }

            buffer[y][x] = newColor;
        }
    }
}

RGBA blendNormal(RGBA color, RGBA mask)
{
    float newAlpha = color.a + mask.a * (1 - color.a);
    if (newAlpha == 0)
    {
        return RGBA(0, 0, 0, 0);
    }

    return RGBA(
        cast(ubyte)((color.r * color.a * (1 - mask.a) + mask.r * mask.a) / newAlpha),
        cast(ubyte)((color.g * color.a * (1 - mask.a) + mask.g * mask.a) / newAlpha),
        cast(ubyte)((color.b * color.a * (1 - mask.a) + mask.b * mask.a) / newAlpha),
        newAlpha
    );
}

RGBA blendAdditive(RGBA color, RGBA mask)
{
    import Math = api.math;

    const max = RGBA.maxColor;

    return RGBA(
        cast(ubyte) Math.min(color.r + mask.r, max),
        cast(ubyte) Math.min(color.g + mask.g, max),
        cast(ubyte) Math.min(color.b + mask.b, max),
        Math.min(color.a + mask.a, 1.0)
    );
}

RGBA blendSubtract(RGBA color, RGBA mask)
{
    return RGBA(
        cast(ubyte) Math.max(color.r - mask.r, 0),
        cast(ubyte) Math.max(color.g - mask.g, 0),
        cast(ubyte) Math.max(color.b - mask.b, 0),
        color.a
    );
}

RGBA blendMultiply(RGBA color, RGBA mask)
{
    const max = RGBA.maxColor;

    return RGBA(
        cast(ubyte)(color.r * mask.r / max),
        cast(ubyte)(color.g * mask.g / max),
        cast(ubyte)(color.b * mask.b / max),
        color.a
    );
}

RGBA blendDivide(RGBA color, RGBA mask)
{
    return RGBA(
        divide(color.r, mask.r),
        divide(color.g, mask.g),
        divide(color.b, mask.b),
        color.a
    );
    return color;
}

private ubyte divide(ubyte color, ubyte mask)
{
    import Math = api.math;

    const max = RGBA.maxColor;

    if (mask == 0)
    {
        //or max
        return color;
    }
    return cast(ubyte) Math.min((color * max) / mask, max);
}

RGBA blendDarken(RGBA color, RGBA mask)
{
    import Math = api.math;

    return RGBA(
        Math.min(color.r, mask.r),
        Math.min(color.g, mask.g),
        Math.min(color.b, mask.b),
        color.a
    );
}

RGBA blendLighten(RGBA color, RGBA mask)
{
    import Math = api.math;

    return RGBA(
        Math.max(color.r, mask.r),
        Math.max(color.g, mask.g),
        Math.max(color.b, mask.b),
        color.a
    );
}

RGBA blendScreen(RGBA color, RGBA mask)
{
    const max = RGBA.maxColor;

    return RGBA(
        cast(ubyte)(max - (max - color.r) * (max - mask.r) / max),
        cast(ubyte)(max - (max - color.g) * (max - mask.g) / max),
        cast(ubyte)(max - (max - color.b) * (max - mask.b) / max),
        color.a
    );
}

RGBA blendOverlay(RGBA color, RGBA mask)
{
    return RGBA(
        overlay(color.r, mask.r),
        overlay(color.g, mask.g),
        overlay(color.b, mask.b),
        color.a
    );
}

private ubyte overlay(ubyte b, ubyte c)
{
    const float max = RGBA.maxColor;

    const bn = b / max, cn = c / max;
    const r = (bn <= 0.5) ? 2 * bn * cn : 1 - 2 * (1 - bn) * (1 - cn);
    return cast(ubyte)(r * max);
}

RGBA blendSoftLight(RGBA color, RGBA mask)
{
    return RGBA(
        soft(color.r, mask.r),
        soft(color.g, mask.g),
        soft(color.b, mask.b),
        color.a
    );
}

private ubyte soft(ubyte color, ubyte mask)
{
    const float max = RGBA.maxColor;

    float b = color / max;
    float c = mask / max;
    float r = 0;
    if (c <= 0.5)
    {
        r = 2 * b * c + b * b * (1 - 2 * c);
    }
    else
    {
        r = 2 * b * (1 - c) + Math.sqrt(b) * (2 * c - 1);
    }
    return cast(ubyte)(r * max + 0.5);
}

RGBA blendrDodge(RGBA color, RGBA mask)
{
    return RGBA(
        dodge(color.r, mask.r),
        dodge(color.g, mask.g),
        dodge(color.b, mask.b),
        color.a
    );
}

private ubyte dodge(ubyte color, ubyte mask)
{
    const max = RGBA.maxColor;

    if (mask == max)
    {
        return max;
    }

    return cast(ubyte) Math.min(max, (color * max) / (max - mask));
}

RGBA blendDifference(RGBA color, RGBA mask)
{
    return RGBA(
        cast(ubyte) Math.abs(color.r - mask.r),
        cast(ubyte) Math.abs(color.g - mask.g),
        cast(ubyte) Math.abs(color.b - mask.b),
        color.a
    );
}

RGBA blendExclusion(RGBA color, RGBA mask)
{
    return RGBA(
        exclusion(color.r, mask.r),
        exclusion(color.g, mask.g),
        exclusion(color.b, mask.b),
        color.a
    );
}

private ubyte exclusion(ubyte color, ubyte mask)
{
    const max = RGBA.maxColor;

    return cast(ubyte)(color + mask - 2 * color * mask / max);
}

RGBA blendBurn(RGBA color, RGBA mask)
{
    return RGBA(
        burn(color.r, mask.r),
        burn(color.g, mask.g),
        burn(color.b, mask.b),
        color.a
    );
}

private ubyte burn(ubyte color, ubyte mask)
{
    if (mask == 0)
    {
        return 0;
    }

    const max = RGBA.maxColor;

    return cast(ubyte)(max - Math.min(max, (max - color) * max / mask));
}

RGBA blendOneColor(RGBA color, RGBA mask)
{
    return RGBA(
        onecolor(color.r, mask.r),
        onecolor(color.g, mask.g),
        onecolor(color.b, mask.b),
        color.a
    );
}

private ubyte onecolor(ubyte color, ubyte mask)
{
    const max = RGBA.maxColor;

    return (color + mask >= max) ? max : 0;
}

RGBA blendHue(RGBA color, RGBA mask)
{

    auto colorHsl = color.toHSLA;
    auto maskHsl = mask.toHSLA;

    import api.dm.kit.graphics.colors.hsla : HSLA;

    auto result = HSLA(maskHsl.h, colorHsl.s, colorHsl.l);
    return result.toRGBA;
}

RGBA blendSaturation(RGBA color, RGBA mask)
{

    auto colorHsl = color.toHSLA;
    auto maskHsl = mask.toHSLA;

    import api.dm.kit.graphics.colors.hsla : HSLA;

    auto result = HSLA(colorHsl.h, maskHsl.s, colorHsl.l);
    return result.toRGBA;
}

RGBA blendColor(RGBA color, RGBA mask)
{

    auto colorHsl = color.toHSLA;
    auto maskHsl = mask.toHSLA;

    import api.dm.kit.graphics.colors.hsla : HSLA;

    auto result = HSLA(maskHsl.h, maskHsl.s, colorHsl.l);
    return result.toRGBA;
}

RGBA blendLuminosity(RGBA color, RGBA mask)
{
    auto colorHsl = color.toHSLA;
    auto maskHsl = mask.toHSLA;

    import api.dm.kit.graphics.colors.hsla : HSLA;

    auto result = HSLA(maskHsl.h, maskHsl.s, colorHsl.l);
    return result.toRGBA;
}

RGBA blendPinlight(RGBA color, RGBA mask, ubyte treshold = 128)
{
    return RGBA(
        pinlight(color.r, mask.r, treshold),
        pinlight(color.g, mask.g, treshold),
        pinlight(color.b, mask.b, treshold),
        color.a
    );
}

private ubyte pinlight(ubyte color, ubyte mask, ubyte treshold = 128)
{
    if (mask > treshold)
        return Math.max(color, mask);
    else
        return Math.min(color, mask);
}
