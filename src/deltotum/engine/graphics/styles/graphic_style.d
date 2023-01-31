module deltotum.engine.graphics.styles.graphic_style;

import deltotum.engine.graphics.colors.rgba : RGBA;

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
