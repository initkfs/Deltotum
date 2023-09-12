module deltotum.gui.controls.control;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.sprites.layouts.layout : Layout;
import deltotum.math.geom.insets : Insets;
import deltotum.kit.sprites.textures.texture : Texture;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.sprites.alignment : Alignment;

/**
 * Authors: initkfs
 */
class Control : Sprite
{
    enum ActionType : string
    {
        standard = "standard",
        success = "success",
        warning = "warning",
        danger = "danger"
    }

    string actionType = ActionType.standard;

    Insets backgroundInsets;
    Sprite delegate(double, double) backgroundFactory;

    GraphicStyle style;

    bool isBackground;
    bool isBorder;
    bool isFocusable;

    //protected
    //{
    Sprite background;
    //}

    this() pure @safe
    {
        isResizedByParent = true;
        isResizable = true;
        isLayoutManaged = true;
        isResizeChildren = true;
    }

    override void initialize()
    {
        super.initialize;

        invalidateListeners ~= () {
            if (!isCreated)
            {
                return;
            }

            if (id == "tab_pane_header_separator")
            {
                import std;

                writefln("sep invalid: %s, %s", width, height);
            }

            checkBackground;
        };

        style = graphics.theme.controlStyle;

        if (!backgroundFactory)
        {
            backgroundFactory = (width, height) {

                import deltotum.kit.graphics.shapes.regular_polygon : RegularPolygon;
                import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

                GraphicStyle backgroundStyle = GraphicStyle(isBorder ? 1 : 0, graphics.theme.colorAccent, isBackground, graphics
                        .theme.colorControlBackground);

                auto background = new RegularPolygon(width, height, backgroundStyle, graphics
                        .theme.controlCornersBevel);
                background.id = "control_background";

                background.opacity = graphics.theme.opacityControls;
                return background;
            };
        }
    }

    GraphicStyle styleFromActionType()
    {
        import deltotum.kit.graphics.colors.rgba : RGBA;

        //TODO remove switch
        RGBA borderColor = graphics.theme.colorAccent;
        RGBA fillColor = graphics.theme.colorControlBackground;

        if (actionType != ActionType.standard)
        {
            final switch (actionType) with (ActionType)
            {
            case standard:
                break;
            case success:
                borderColor = graphics.theme.colorSuccess;
                fillColor = borderColor;
                break;
            case warning:
                borderColor = graphics.theme.colorWarning;
                fillColor = borderColor;
                break;
            case danger:
                borderColor = graphics.theme.colorDanger;
                fillColor = borderColor;
                break;
            }
        }
        return GraphicStyle(isBorder ? 1 : 0, borderColor, isBackground, fillColor);
    }

    protected bool createBackground(double width, double height)
    {
        if (
            background ||
            width == 0 ||
            height == 0 ||
            (!isBackground && !isBorder)
            || !backgroundFactory)
        {
            return false;
        }

        if (id == "tab_pane_header_separator")
        {
            import std;

            writefln("sep: %s, %s", width, height);
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

    override void addCreate(Sprite[] sprites)
    {
        super.addCreate(sprites);
    }

    override void addCreate(Sprite sprite, long index = -1)
    {
        super.addCreate(sprite, index);
    }

    override void create()
    {
        super.create;

        createBackground(width, height);
    }

    void checkBackground()
    {
        if (id == "tab_pane_header_separator")
        {
            import std;

            writefln("sep: %s, %s", width, height);
        }

        if (background)
        {
            import std;

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
