module dm.gui.controls.control;

import dm.kit.sprites.sprite : Sprite;
import dm.kit.sprites.layouts.layout : Layout;
import dm.math.geom.insets : Insets;
import dm.kit.sprites.textures.texture : Texture;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.math.geom.alignment : Alignment;

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

            checkBackground;
        };

        if (!backgroundFactory)
        {
            backgroundFactory = (width, height) {

                import dm.kit.sprites.shapes.regular_polygon : RegularPolygon;
                import dm.kit.graphics.styles.graphic_style : GraphicStyle;

                GraphicStyle* currStyle = ownOrParentStyle;

                GraphicStyle backgroundStyle = currStyle ? *currStyle : GraphicStyle(isBorder ? 1 : 0, graphics.theme.colorAccent, isBackground, graphics
                        .theme.colorControlBackground);

                auto background = new RegularPolygon(width, height, backgroundStyle, graphics
                        .theme.controlCornersBevel);
                background.id = "control_background";

                background.opacity = graphics.theme.opacityControls;
                return background;
            };
        }
    }

    void addCreateIcon(string iconName)
    {
        auto icon = createIcon(iconName);
        addCreate(icon);
    }

    //TODO or move to scene factory?
    Sprite createIcon(string iconName)
    {
        assert(isCreated);

        import dm.kit.graphics.themes.icons.icon_name;
        import dm.kit.sprites.images.image : Image;

        import std.conv : to;

        const mustBeIconData = graphics.theme.iconData(iconName);
        if(mustBeIconData.isNull){
            //TODO placeholder;
            import dm.kit.sprites.shapes.rectangle: Rectangle;
            import dm.kit.graphics.styles.graphic_style: GraphicStyle;
            import dm.kit.graphics.colors.rgba: RGBA;
            return new Rectangle(10, 10, GraphicStyle(1, RGBA.red, true, RGBA.red));
        }
        const string iconData = mustBeIconData.get;
        auto icon = new Image();
        build(icon);
        const iconSize = graphics.theme.iconSize;
        import std.conv: to;
        icon.loadRaw(iconData.to!(const(void[])), iconSize.to!int, iconSize.to!int);

        auto color = graphics.theme.colorAccent;
        if(style){
            color = style.lineColor;
        }

        icon.color = color;
        icon.create;
        return icon;
    }

    GraphicStyle styleFromActionType()
    {
        import dm.kit.graphics.colors.rgba : RGBA;

        auto currStyle = ownOrParentStyle;
        //TODO remove switch
        RGBA borderColor = currStyle ? currStyle.lineColor : graphics.theme.colorAccent;
        RGBA fillColor = currStyle ? currStyle.fillColor : graphics.theme.colorControlBackground;

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
