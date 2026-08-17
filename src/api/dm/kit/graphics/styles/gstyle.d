module api.dm.kit.graphics.styles.gstyle;

import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
struct GStyle
{
    float lineWidth = 1;
    RGBA lineColor = RGBA.lime;

    bool isFill;
    RGBA fillColor = RGBA.transparent;
    bool isNested;
    bool isDefault;
    string name;

    static pure @safe
    {
        GStyle simple() => GStyle(1, RGBA.lightcyan, false, RGBA.transparent);
        GStyle simpleFill() => GStyle(1, RGBA.lightcyan, true, RGBA.red);
        GStyle transparentFill() => GStyle(1, RGBA.transparent, true, RGBA.transparent);
    }

    void color(RGBA color)
    {
        fillColor = color;
        lineColor = color;
    }

    GStyle copyOfColor(RGBA color)
    {
        auto copy = this;
        copy.lineColor = color;
        return copy;
    }

    GStyle copyOfFillColor(RGBA color)
    {
        auto copy = this;
        copy.fillColor = color;
        return copy;
    }

    bool isPreset() => isDefault || isNested;
}
