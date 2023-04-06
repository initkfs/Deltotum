module deltotum.ui.containers.container;

import deltotum.ui.controls.control : Control;
import deltotum.toolkit.display.display_object : DisplayObject;

/**
 * Authors: initkfs
 */
class Container : Control
{
    override void initialize()
    {
        super.initialize;

        backgroundFactory = (width, height) {

            import deltotum.toolkit.graphics.shapes.rectangle : Rectangle;
            import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;

            GraphicStyle backgroundStyle = GraphicStyle(0, graphics.theme.colorContainerBackground, true, graphics
                    .theme.colorContainerBackground);

            auto background = new Rectangle(width, height, backgroundStyle);
            background.opacity = graphics.theme.opacityContainer;
            return background;
        };
    }
}
