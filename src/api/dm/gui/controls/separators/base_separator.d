module api.dm.gui.controls.separators.base_separator;

import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
abstract class BaseSeparator : Control
{
    this()
    {
        isBackground = true;
    }

    override Sprite2d newBackground()
    {
        auto shape = theme.rectShape(width, height, angle, createBackgroundStyle);
        return shape;
    }

    override GraphicStyle createBackgroundStyle()
    {
        auto style = createFillStyle;
        return style;
    }

}
