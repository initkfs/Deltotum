module deltotum.graphics.styles.graphic_style;

import deltotum.graphics.colors.color : Color;

/**
 * Authors: initkfs
 */
struct GraphicStyle
{
    double lineWidth;
    Color lineColor;
    bool isFill;
    Color fillColor;

    static GraphicStyle simple(){
        return GraphicStyle(1.0, Color.white, false, Color.transparent);
    }
}
