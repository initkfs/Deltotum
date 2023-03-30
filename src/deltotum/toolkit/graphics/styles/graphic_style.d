module deltotum.toolkit.graphics.styles.graphic_style;

import deltotum.toolkit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
struct GraphicStyle
{
    double lineWidth = 0;
    RGBA lineColor = RGBA.white;

    bool isFill;
    RGBA fillColor = RGBA.transparent;

    static GraphicStyle simple()
    {
        return GraphicStyle(1.0, RGBA.white, false, RGBA.transparent);
    }
}
