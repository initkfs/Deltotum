module deltotum.ui.controls.control;

import deltotum.toolkit.display.display_object : DisplayObject;
import deltotum.toolkit.display.layouts.layout : Layout;
import deltotum.maths.geometry.insets : Insets;
import deltotum.toolkit.display.textures.texture : Texture;
import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.toolkit.display.alignment : Alignment;

/**
 * Authors: initkfs
 */
abstract class Control : DisplayObject
{
    Insets backgroundInsets;
    Texture delegate(double, double) backgroundFactory;

    GraphicStyle style;

    protected
    {
        Texture background;
    }

    override void initialize()
    {
        super.initialize;

        padding = graphics.theme.controlPadding;
        style = graphics.theme.controlStyle;

        backgroundFactory = (width, height) {

            import deltotum.toolkit.graphics.shapes.rectangle : Rectangle;
            import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;

            GraphicStyle backgroundStyle = GraphicStyle(1, graphics.theme.colorAccent, false, graphics
                    .theme.colorControlBackground);

            auto background = new Rectangle(width, height, backgroundStyle);
            background.opacity = graphics.theme.opacityControl;
            return background;
        };
    }

    bool createBackground(double width, double height)
    {
        if (backgroundFactory is null)
        {
            return false;
        }

        background = backgroundFactory(width, height);
        return true;
    }

    override void create()
    {
        super.create;

        if (width > 0 && height > 0)
        {
            createBackground(width - backgroundInsets.width, height - backgroundInsets.height);
            if (background !is null)
            {
                background.x = backgroundInsets.left;
                background.y = backgroundInsets.top;
                background.isLayoutManaged = false;
                addCreated(background);
            }
        }else {
            logger.tracef("Dimensions not set, background cannot be created. Width: %s, height: %s in %s", width, height, className);
        }
    }
}
