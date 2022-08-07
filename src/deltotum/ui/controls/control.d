module deltotum.ui.controls.control;

import deltotum.display.display_object : DisplayObject;
import deltotum.ui.theme.theme : Theme;
import deltotum.display.layouts.layout : Layout;
import deltotum.display.textures.texture : Texture;
import deltotum.graphics.styles.graphic_style : GraphicStyle;

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
        GraphicStyle backgroundStyle;
    }

    @property Texture delegate() backgroundFactory;

    this(Theme theme)
    {
        this.theme = theme;
        backgroundStyle = GraphicStyle(1, theme.colorAccent, true, theme
                .colorSecondary);
        backgroundFactory = () {
            import deltotum.graphics.shapes.rectangle : Rectangle;

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
    }
}
