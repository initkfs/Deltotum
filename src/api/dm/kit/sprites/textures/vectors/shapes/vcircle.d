module api.dm.kit.sprites.textures.vectors.shapes.vcircle;

import api.dm.kit.sprites.textures.vectors.shapes.varc: VArc;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.insets: Insets;

import Math = api.dm.math;

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
