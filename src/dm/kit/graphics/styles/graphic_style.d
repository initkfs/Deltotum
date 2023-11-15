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

    static GraphicStyle simple() @nogc pure @safe
    {
        return GraphicStyle(1.0, RGBA.white, false, RGBA.transparent);
    }
}
