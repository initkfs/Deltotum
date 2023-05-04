module deltotum.gui.controls.control;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.sprites.layouts.layout : Layout;
import deltotum.math.geometry.insets : Insets;
import deltotum.kit.sprites.textures.texture : Texture;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.sprites.alignment : Alignment;

/**
 * Authors: initkfs
 */
abstract class Control : Sprite
{
    Insets backgroundInsets;
    Texture delegate(double, double) backgroundFactory;

    GraphicStyle style;

    bool isBackground = true;

    protected
    {
        Texture background;
    }

    override void initialize()
    {
        super.initialize;

        padding = graphics.theme.controlPadding;
        style = graphics.theme.controlStyle;

        if (isBackground)
        {
            backgroundFactory = (width, height) {

                import deltotum.kit.graphics.shapes.regular_polygon : RegularPolygon;

                // import deltotum.kit.graphics.shapes.rectangle : Rectangle;
                // import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

                GraphicStyle backgroundStyle = GraphicStyle(1, graphics.theme.colorAccent, false, graphics
                        .theme.colorControlBackground);

                auto background = new RegularPolygon(width, height, backgroundStyle, graphics
                        .theme.controlCornersBevel);

                // auto background = new Rectangle(width, height, backgroundStyle);
                background.opacity = graphics.theme.opacityControls;
                return background;
            };
        }
    }

    protected bool createBackground(double width, double height)
    {
        if (!isBackground || backgroundFactory is null)
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
                background.isResizedByParent = true;
                background.isLayoutManaged = false;
                addCreated(background);
            }
        }
        // else
        // {
        //     logger.tracef("Dimensions not set, background cannot be created. Width: %s, height: %s in %s", width, height, className);
        // }
    }
}
