module deltotum.gui.controls.separators.separator;

import deltotum.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
abstract class Separator : Control
{
    this() pure @safe
    {

    }

    override void initialize()
    {        
        backgroundFactory = (width, height) {

            import deltotum.kit.graphics.shapes.rectangle : Rectangle;
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

            GraphicStyle backgroundStyle = GraphicStyle(isBorder ? 1 : 0, graphics.theme.colorAccent, isBackground, graphics
                    .theme.colorControlBackground);

            auto background = new Rectangle(width, height, backgroundStyle);
            background.id = "separator_background";

            background.opacity = graphics.theme.opacityControls;
            return background;
        };

        super.initialize;
    }

}
