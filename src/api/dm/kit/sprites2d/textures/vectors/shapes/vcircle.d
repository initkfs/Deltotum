module api.dm.kit.sprites2d.textures.vectors.shapes.vcircle;

import api.dm.kit.sprites2d.textures.vectors.shapes.varc: VArc;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.pos2.insets: Insets;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class VCircle : VArc
{
    this(float radius = 10, GraphicStyle style = GraphicStyle.simpleFill)
    {
        this(radius, style, radius * 2, radius * 2);
    }

    this(float radius, GraphicStyle style, float width, float height)
    {
        super(radius, style, width, height);
        this.toAngleRad = 2 * Math.PI;
    }
}
