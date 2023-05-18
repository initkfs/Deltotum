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

    this() pure @safe
    {
        isResizedByParent = true;
        isResizable = true;
        isLayoutManaged = true;
    }

    override void initialize()
    {
        super.initialize;

        invalidateListener = () { checkBackground; };

        padding = graphics.theme.controlPadding;
        style = graphics.theme.controlStyle;

        if (isBorder || isBackground)
        {
            backgroundFactory = (width, height) {

                import deltotum.kit.graphics.shapes.regular_polygon : RegularPolygon;
                import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

                GraphicStyle backgroundStyle = GraphicStyle(isBorder ? 1 : 0, graphics.theme.colorAccent, isBackground, graphics
                        .theme.colorControlBackground);

                auto background = new RegularPolygon(width, height, backgroundStyle, graphics
                        .theme.controlCornersBevel);

                background.opacity = graphics.theme.opacityControls;
                return background;
            };
        }
    }

    protected bool createBackground(double width, double height)
    {
        if (
            background ||
            width == 0 ||
            height == 0 ||
            (!isBackground && !isBorder)
            || backgroundFactory is null)
        {
            return false;
        }

        assert(backgroundInsets.width < width);
        assert(backgroundInsets.height < height);

        background = backgroundFactory(width - backgroundInsets.width, height - backgroundInsets
                .height);

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

        createBackground(width, height);
    }

    void checkBackground()
    {
        if (background)
        {
            background.width = width;
            background.height = height;
            return;
        }
        if (width > 0 && height > 0)
        {
            createBackground(width - backgroundInsets.width, height - backgroundInsets.height);
        }
    }
}
