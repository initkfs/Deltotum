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

    static GraphicStyle simple() pure @safe
    {
        return GraphicStyle(1.0, RGBA.white, false, RGBA.transparent);
    }

    static GraphicStyle simpleFill() pure @safe
    {
        return GraphicStyle(1.0, RGBA.lightcyan, true, RGBA.red);
    }

    void color(RGBA color){
        fillColor = color;
        lineColor = color;
    }
}
