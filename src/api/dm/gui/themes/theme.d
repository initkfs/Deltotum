module api.dm.gui.themes.theme;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.com.graphics.com_font : ComFont;
import api.math.pos2.insets : Insets;
import api.dm.kit.graphics.styles.gstyle : GStyle;
import api.dm.gui.themes.theme_style : ThemeStyle;
import api.dm.gui.themes.icons.icon_pack : IconPack;
import api.dm.kit.sprites2d.images.image : Image;
import api.dm.kit.sprites2d.shapes.rshape2d : RShape2d;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.core.configs.uda : ConfigKey;

import api.dm.kit.sprites2d.textures.vectors.vec_shapes.vec_rectangle;

/**
 * Authors: initkfs
 */
class Theme
{
    IconPack iconPack;

    private
    {
        ComFont _defaultMediumFont;
    }

    protected {
        GStyle[string] styles;
    }

    @ConfigKey
    RGBA colorPrimary = RGBA(110, 43, 232);
    @ConfigKey
    RGBA colorSecondary = RGBA(238, 239, 239);
    @ConfigKey
    RGBA colorAccent = RGBA(102, 40, 224);

    @ConfigKey
    RGBA colorFocus = RGBA(255, 228, 132);
    @ConfigKey
    RGBA colorText = RGBA.black;
    @ConfigKey
    RGBA colorBackground = RGBA(248, 249, 250);
    @ConfigKey
    RGBA colorHover = RGBA.white;
    @ConfigKey
    RGBA colorSelect = RGBA(13, 110, 253);

    @ConfigKey
    RGBA colorSuccess = RGBA(40, 167, 69);
    @ConfigKey
    RGBA colorDanger = RGBA(220, 53, 69);
    @ConfigKey
    RGBA colorWarning = RGBA(255, 193, 7);

    @ConfigKey
    RGBA colorControlBackground = RGBA(248, 249, 250);
    @ConfigKey
    RGBA colorContainerBackground = RGBA(248, 249, 250);

    @ConfigKey
    float opacityContainers = 1;
    @ConfigKey
    float opacityControls = 1;
    @ConfigKey
    float opacityBackground = 0.85;
    @ConfigKey
    float opacityHover = 0.4;

    @ConfigKey
    size_t iconSize = 26;

    @ConfigKey
    float layoutIndent = 5;

    @ConfigKey
    int lineThickness = 1;

    @ConfigKey
    Insets controlPadding = Insets(5, 5, 5, 5);

    @ConfigKey
    float controlSpacing = 2;

    @ConfigKey
    float controlCornersBevel = 0;
    GStyle controlStyle = GStyle.simple;

    @ConfigKey
    float controlDefaultWidth = 80;
    @ConfigKey
    float controlDefaultHeight = 35;
    @ConfigKey
    float controlGraphicsGap = 2;

    @ConfigKey
    float buttonWidth = 50;
    @ConfigKey
    float buttonHeight = 35;
    @ConfigKey
    float roundShapeDiameter = 45;
    @ConfigKey
    float regularPolyDiameter = 50;
    @ConfigKey
    size_t regularPolySides = 6;
    @ConfigKey
    float parallelogramShapeAngleDeg = 75;

    bool isUseVectorGraphics;

    @ConfigKey
    size_t actionEffectAnimationDelayMs = 80;
    @ConfigKey
    size_t hoverAnimationDelayMs = 80;
    @ConfigKey
    size_t popupDelayMs = 500;

    @ConfigKey
    float checkMarkerWidth = 20;
    @ConfigKey
    float checkMarkerHeight = 20;

    @ConfigKey
    float toggleSwitchMarkerWidth = 20;
    @ConfigKey
    float toggleSwitchMarkerHeight = 20;

    @ConfigKey
    float separatorHeight = 2;

    @ConfigKey
    float meterThumbWidth = 30;
    @ConfigKey
    float meterThumbHeight = 15;
    @ConfigKey
    float meterThumbDiameter = 60;

    @ConfigKey
    float meterTickMinorWidth = 2;
    @ConfigKey
    float meterTickMinorHeight = 6;
    @ConfigKey
    float meterTickMajorWidth = 2;
    @ConfigKey
    float meterTickMajorHeight = 12;
    @ConfigKey
    float meterHandWidth = 4;

    @ConfigKey
    float loaderSize = 50;

    @ConfigKey
    float dividerSize = 5;

    @ConfigKey
    bool fontIsCreateSmall = true;
    @ConfigKey
    bool fontIsCreateLarge = true;
    @ConfigKey
    uint fontSizeMedium = 15;
    @ConfigKey
    uint fontSizeSmall = 12;
    @ConfigKey
    uint fontSizeLarge = 34;

    version (linux)
    {
        ///usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf
        ///usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
        string fontTTFFile = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf";
    }
    else version (Windows)
    {
        string fontTTFFile = "C:\\Windows\\Fonts\\arial.ttf";
    }
    else version (OSX)
    {
        string fontTTFFile = "/Library/Fonts/Arial.ttf";
    }

    string fontIconsList = "bootstrap-icons.woff";

    @ConfigKey
    uint fontIconsSize = 20;
    @ConfigKey
    float fontAlphaGamma = 1;
    @ConfigKey
    string fontRenderMode = "normal";

    void defaultMediumFont(ComFont font)
    {
        assert(font);
        _defaultMediumFont = font;
    }

    ComFont defaultMediumFont()
    {
        assert(_defaultMediumFont, "Default medium font is null");
        return _defaultMediumFont;
    }

    GStyle* newDefaultStyle()
    {
        return new GStyle(lineThickness, colorAccent, false, colorControlBackground);
    }

    GStyle defaultStyle(GStyle* ownStyle)
    {
        if (ownStyle)
        {
            return *ownStyle;
        }
        return defaultStyle();
    }

    void addStyle(string id, GStyle style, bool isFixed = true){
        style.isFixed = isFixed;
        styles[id] = style;
    }

    GStyle defaultStyle()
    {
        GStyle style = GStyle(lineThickness, colorAccent, false, colorControlBackground);
        return style;
    }

    GStyle* hasStyle(string id)
    {
        if (auto stylePtr = id in styles)
        {
            return stylePtr;
        }

        switch (id) with (ThemeStyle)
        {
            case standard:
                return null;
                break;
            case success:
                auto newStyle = createDefaultStyle;
                newStyle.lineColor = colorSuccess;
                newStyle.fillColor = newStyle.lineColor;
                newStyle.isDefault = true;
                styles[ThemeStyle.success] = newStyle;
                return &styles[ThemeStyle.success];
                break;
            case warning:
                auto newStyle = createDefaultStyle;
                newStyle.lineColor = colorWarning;
                newStyle.fillColor = newStyle.lineColor;
                newStyle.isDefault = true;
                styles[ThemeStyle.warning] = newStyle;
                return &styles[ThemeStyle.warning];
                break;
            case danger:
                auto newStyle = createDefaultStyle;
                newStyle.lineColor = colorDanger;
                newStyle.fillColor = newStyle.lineColor;
                newStyle.isDefault = true;
                styles[ThemeStyle.danger] = newStyle;
                return &styles[ThemeStyle.danger];
                break;
            default:
                break;
        }

        return null;
    }

    GStyle createDefaultStyle()
    {
        return GStyle(lineThickness, colorAccent, false, colorControlBackground);
    }

    //TODO @safe
    Sprite2d background(float width, float height, float angle, scope GStyle* parentStyle = null)
    {
        import api.dm.kit.graphics.styles.gstyle : GStyle;

        GStyle backgroundStyle = parentStyle ? *parentStyle : GStyle(
            lineThickness, colorAccent, true, colorControlBackground);

        return shape(width, height, angle, backgroundStyle);
    }

    Sprite2d shape(float width, float height, float angle, GStyle style)
    {
        return convexPolyShape(width, height, angle, controlCornersBevel, style);
    }

    Sprite2d convexPolyShape(float width, float height, float angle, float cornerBevel, GStyle style)
    {
        Sprite2d newShape;
        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.vec_shapes.vec_convex_poly : VecConvexPoly;

            newShape = new VecConvexPoly(width, height, style, cornerBevel);
        }
        else
        {
            //if (style.isFill)
            //{
            return rectShape(width, height, angle, style);
            // }

            //import api.dm.kit.sprites2d.shapes.rconvex_poly : RConvexPoly;

            //newShape = new RConvexPoly(width, height, style, cornerBevel);
        }

        newShape.angle = angle;
        return newShape;
    }

    Sprite2d rectShape(float width, float height, float angle, GStyle style)
    {
        Sprite2d shape;
        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.vec_shapes.vec_rectangle : VecRectangle;

            shape = new VecRectangle(width, height, style);
        }
        else
        {
            import api.dm.kit.sprites2d.shapes.rrect : RRect;

            shape = new RRect(width, height, style);
        }
        shape.angle = angle;
        return shape;
    }

    Sprite2d circleShape(GStyle style) => circleShape(roundShapeDiameter, style);

    Sprite2d circleShape(float diameter, GStyle style)
    {
        float radius = diameter / 2;

        Sprite2d shape;
        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.vec_shapes.vec_circle : VecCircle;

            shape = new VecCircle(radius, style);
        }
        else
        {
            import api.dm.kit.sprites2d.shapes.rcircle : RCircle;

            shape = new RCircle(radius, style);
        }
        return shape;
    }

    Sprite2d regularPolyShape(float angle, GStyle style) => regularPolyShape(
        regularPolyDiameter, regularPolySides, angle, style);

    Sprite2d regularPolyShape(float size, size_t sides, float angle, GStyle style)
    {
        Sprite2d shape;

        import Math = api.math;

        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.vec_shapes.vec_regular_poly : VecRegularPoly;

            shape = new VecRegularPoly(size, style, sides);
        }
        else
        {
            import api.dm.kit.sprites2d.shapes.rreqular_poly : RRegularPoly;

            shape = new RRegularPoly(size, style, sides);
        }

        shape.angle = angle;

        return shape;
    }

    Sprite2d triangleShape(float width, float height, float angleDeg, GStyle style)
    {

        Sprite2d shape;

        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.vec_shapes.vec_triangle : VecTriangle;

            shape = new VecTriangle(width, height, style);
        }
        else
        {
            import api.dm.kit.sprites2d.shapes.rtriangle : RTriangle;

            shape = new RTriangle(width, height, style);
        }

        assert(shape);
        shape.angle = angleDeg;
        return shape;
    }

}
