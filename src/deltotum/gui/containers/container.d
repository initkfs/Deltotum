module deltotum.gui.containers.container;

import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class Container : Control
{
    override void initialize()
    {
        super.initialize;

        backgroundFactory = (width, height) {

            import deltotum.kit.graphics.shapes.rectangle : Rectangle;
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

            GraphicStyle backgroundStyle = GraphicStyle(0, graphics.theme.colorContainerBackground, true, graphics
                    .theme.colorContainerBackground);

            auto background = new Rectangle(width, height, backgroundStyle);
            background.opacity = graphics.theme.opacityContainers;
            return background;
        };
    }
}
