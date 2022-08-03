module deltotum.ui.controls.control;

import deltotum.display.display_object : DisplayObject;
import deltotum.ui.theme.theme : Theme;
import deltotum.ui.layouts.layout : Layout;
import deltotum.display.texture.texture : Texture;
import deltotum.graphics.shape.shape_style : ShapeStyle;

/**
 * Authors: initkfs
 */
class Control : DisplayObject
{
    @property double minWidth = 0;
    @property double mnHeight = 0;
    @property double maxWidth = 0;
    @property double maxHeight = 0;
    @property double prefWidth = 0;
    @property double prefHeight = 0;

    @property Layout layout;

    @property void delegate() invalidateListener;

    @property Theme theme;

    protected
    {
        Texture background;
        ShapeStyle* backgroundStyle;
    }

    @property Texture delegate() backgroundFactory;

    this(Theme theme)
    {
        this.theme = theme;
        backgroundFactory = () {
            import deltotum.graphics.shape.rectangle : Rectangle;
            import deltotum.graphics.shape.shape_style : ShapeStyle;

            if (backgroundStyle is null)
            {
                backgroundStyle = new ShapeStyle(1, theme.colorAccent, true, theme
                        .colorSecondary);
            }

            auto background = new Rectangle(width, height, backgroundStyle);
            background.opacity = theme.controlOpacity;
            background.isLayoutManaged = false;
            return background;
        };
    }

    bool createBackground()
    {
        if (backgroundFactory is null)
        {
            return false;
        }

        background = backgroundFactory();
        addCreated(background);
        return true;
    }

    override void create()
    {
        super.create;
        if (layout !is null)
        {
            layout.layout(this);
        }
    }

    void invalidate()
    {
        if (layout !is null)
        {
            layout.layout(this);
        }

        if (!isRedraw)
        {
            requestRedraw;
        }

        if (invalidateListener !is null)
        {
            invalidateListener();
        }
    }

    override void destroy()
    {
        super.destroy;
        if (background !is null)
        {
            background.destroy;
        }
        backgroundFactory = null;

        //TODO destroy?
        backgroundStyle = null;
    }
}
