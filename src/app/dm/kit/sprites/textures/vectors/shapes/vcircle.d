module app.dm.kit.sprites.textures.vectors.shapes.vcircle;

import app.dm.kit.sprites.textures.vectors.shapes.varc: VArc;
import app.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import app.dm.math.insets: Insets;

import Math = app.dm.math;

/**
 * Authors: initkfs
 */
class VCircle : VArc
{
    this(double radius, GraphicStyle style)
    {
        this(radius, style, radius * 2, radius * 2);
    }

    this(double radius, GraphicStyle style, double width, double height)
    {
        super(radius, style, width, height);
        this.toAngleRad = 2 * Math.PI;
    }
}
