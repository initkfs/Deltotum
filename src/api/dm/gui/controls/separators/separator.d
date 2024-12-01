module api.dm.gui.controls.separators.separator;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
abstract class Separator : Control
{
    override Sprite2d newBackground(double width, double height)
    {
        import api.dm.kit.sprites.sprites2d.shapes.rectangle : Rectangle;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        GraphicStyle backgroundStyle = GraphicStyle(isBorder ? 1 : 0, theme.colorAccent, isBackground, theme
                .colorControlBackground);

        auto background = new Rectangle(width, height, backgroundStyle);
        background.id = "separator_background";

        background.opacity = theme.opacityControls;
        return background;
    }

}
