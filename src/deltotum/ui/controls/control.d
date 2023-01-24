module deltotum.ui.controls.control;

import deltotum.display.display_object : DisplayObject;
import deltotum.display.layouts.layout : Layout;
import deltotum.display.textures.texture : Texture;
import deltotum.graphics.styles.graphic_style : GraphicStyle;
import deltotum.display.padding: Padding;

/**
 * Authors: initkfs
 */
class Control : DisplayObject
{
    double minWidth = 0;
    double mnHeight = 0;
    double maxWidth = 0;
    double maxHeight = 0;
    double prefWidth = 0;
    double prefHeight = 0;
    Padding padding;

    Texture delegate(double, double) backgroundFactory;

    Layout layout;

    protected
    {
        Texture background;
        GraphicStyle backgroundStyle;
        bool valid = true;
    }

    this()
    {
        backgroundFactory = (width, height) {
            import deltotum.graphics.shapes.rectangle : Rectangle;

            auto background = new Rectangle(width, height, backgroundStyle);
            background.opacity = graphics.theme.controlOpacity;
            background.isLayoutManaged = false;
            return background;
        };
    }

    bool createBackground(double w, double h)
    {
        if (backgroundFactory is null)
        {
            return false;
        }

        background = backgroundFactory(w, h);
        addCreated(background);
        return true;
    }

    void resizeContent(double newWidth, double newHeight)
    {
        if (background !is null)
        {
            background.destroy;
            bool isRemoved = remove(background);
            if (!isRemoved)
            {
                //TODO log errors
            }
        }

        createBackground(newWidth, newHeight);
    }

    override void create()
    {
        super.create;

        backgroundStyle = GraphicStyle(1, graphics.theme.colorAccent, true, graphics
                .theme
                .colorSecondary);

        padding = graphics.theme.controlPadding;

        onInvalidateWidth = (newWidth) { resizeContent(newWidth, height); };
        onInvalidateHeight = (newHeight) { resizeContent(width, newHeight); };
    }

    protected void applyLayout()
    {
        if (layout !is null)
        {
            layout.layout(this);
        }
    }

    override void invalidate()
    {

    }

    override void destroy()
    {
        super.destroy;
        if (background !is null)
        {
            background.destroy;
        }
        backgroundFactory = null;
    }
}
