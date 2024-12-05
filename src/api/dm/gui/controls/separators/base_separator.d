module api.dm.gui.controls.separators.base_separator;

import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
abstract class BaseSeparator : Control
{
    this()
    {
        isBackground = true;
    }

    override Sprite2d newBackground(double w, double h)
    {
        auto shape = theme.rectShape(w, h, angle, createThisStyle);
        return shape;
    }

    override GraphicStyle createThisStyle()
    {
        auto style = createFillStyle;
        return style;
    }

}
