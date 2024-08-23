module api.dm.gui.controls.separators.separator;

import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
abstract class Separator : Control
{
    override void initialize()
    {        
        backgroundFactory = (width, height) {

            import api.dm.kit.sprites.shapes.rectangle : Rectangle;
            import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

            auto currStyle = ownOrParentStyle;

            GraphicStyle backgroundStyle = currStyle ? *currStyle : GraphicStyle(isBorder ? 1 : 0, graphics.theme.colorAccent, isBackground, graphics
                    .theme.colorControlBackground);

            auto background = new Rectangle(width, height, backgroundStyle);
            background.id = "separator_background";

            background.opacity = graphics.theme.opacityControls;
            return background;
        };

        super.initialize;
    }

}
