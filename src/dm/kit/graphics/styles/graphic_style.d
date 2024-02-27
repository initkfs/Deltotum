module dm.kit.graphics.styles.graphic_style;

import dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
struct GraphicStyle
{
    double lineWidth = 0;
    RGBA lineColor = RGBA.white;

    bool isFill;
    RGBA fillColor = RGBA.transparent;
    bool isNested;

    static GraphicStyle simple() @nogc pure @safe
    {
        return GraphicStyle(1.0, RGBA.white, false, RGBA.transparent);
    }

    void color(RGBA color){
        fillColor = color;
        lineColor = color;
    }
}
