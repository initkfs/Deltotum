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
    Sprite delegate(double, double) backgroundFactory;

    GraphicStyle style;

    bool isBackground = true;
    bool isBorder = true;

    protected
    {
        Sprite background;
    }

    override void initialize()
    {
        super.initialize;

        isResizedByParent = true;
        isResizable = true;
        isLayoutManaged = true;

        padding = graphics.theme.controlPadding;
        style = graphics.theme.controlStyle;

        backgroundFactory = (width, height) {

            import deltotum.kit.graphics.shapes.regular_polygon : RegularPolygon;
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

            const borderLineWidth = isBorder ? 1 : 0;
        
            GraphicStyle backgroundStyle = GraphicStyle(borderLineWidth, graphics.theme.colorAccent, false, graphics
                    .theme.colorControlBackground);

            auto background = new RegularPolygon(width, height, backgroundStyle, graphics
                    .theme.controlCornersBevel);

            // auto background = new Rectangle(width, height, backgroundStyle);
            background.opacity = graphics.theme.opacityControls;
            return background;
        };
    }

    protected bool createBackground(double width, double height)
    {
        if (background || (!isBackground && !isBorder) || backgroundFactory is null)
        {
            return false;
        }

        background = backgroundFactory(width, height);
        background.x = backgroundInsets.left;
        background.y = backgroundInsets.top;
        background.isResizedByParent = true;
        background.isLayoutManaged = false;
        addCreate(background, 0);
        return true;
    }

    override void create()
    {
        super.create;

        if (width > 0 && height > 0)
        {
            createBackground(width - backgroundInsets.width, height - backgroundInsets.height);
        }
        // else
        // {
        //     logger.tracef("Dimensions not set, background cannot be created. Width: %s, height: %s in %s", width, height, className);
        // }
    }
}
