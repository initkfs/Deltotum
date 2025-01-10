module api.dm.kit.graphics.styles.graphic_style;

import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
struct GraphicStyle
{
    double lineWidth = 1;
    RGBA lineColor = RGBA.lime;

    bool isFill;
    RGBA fillColor = RGBA.transparent;
    bool isNested;
    bool isDefault;
    string name;

    static pure @safe
    {
        GraphicStyle simple() => GraphicStyle(1, RGBA.lightcyan, false, RGBA.transparent);
        GraphicStyle simpleFill() => GraphicStyle(1, RGBA.lightcyan, true, RGBA.red);
        GraphicStyle transparentFill() => GraphicStyle(1, RGBA.transparent, true, RGBA.transparent);
    }

    void color(RGBA color)
    {
        fillColor = color;
        lineColor = color;
    }

    GraphicStyle copyOfColor(RGBA color)
    {
        auto copy = this;
        copy.lineColor = color;
        return copy;
    }

    GraphicStyle copyOfFillColor(RGBA color)
    {
        auto copy = this;
        copy.fillColor = color;
        return copy;
    }

    bool isPreset() => isDefault || isNested;
}
