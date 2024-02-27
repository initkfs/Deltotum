module dm.kit.sprites.textures.vectors.vcircle;

import dm.kit.sprites.textures.vectors.varc: VArc;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;

import Math = dm.math;

/**
 * Authors: initkfs
 */
class VCircle : VArc
{
    this(double radius, GraphicStyle style)
    {
        super(radius, style);

        this.toAngleRad = 2 * Math.PI;
    }
}
