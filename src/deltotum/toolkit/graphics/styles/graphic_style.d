module deltotum.toolkit.graphics.styles.graphic_style;

import deltotum.toolkit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
struct GraphicStyle
{
    double lineWidth;
    RGBA lineColor;
    bool isFill;
    RGBA fillColor;

    static GraphicStyle simple(){
        return GraphicStyle(1.0, RGBA.white, false, RGBA.transparent);
    }
}
