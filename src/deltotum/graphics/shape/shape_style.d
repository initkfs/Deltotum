module deltotum.graphics.shape.shape_style;

import deltotum.graphics.colors.color : Color;

/**
 * Authors: initkfs
 */
struct ShapeStyle
{
    double lineWidth;
    Color lineColor;
    bool isFill;
    Color fillColor;

    static ShapeStyle simple(){
        return ShapeStyle(1.0, Color.white, false, Color.transparent);
    }
}
