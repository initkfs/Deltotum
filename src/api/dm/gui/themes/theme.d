module api.dm.gui.themes.theme;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.com.graphics.com_font : ComFont;
import api.math.pos2.insets : Insets;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.themes.icons.icon_pack : IconPack;
import api.dm.kit.sprites2d.images.image : Image;
import api.dm.kit.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.core.configs.uda : ConfigKey;

import api.dm.kit.sprites2d.textures.vectors.shapes.vec_rectangle;

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
    float opacityHover = 1;

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
    GraphicStyle controlStyle = GraphicStyle.simple;

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

    GraphicStyle* newDefaultStyle()
    {
        return new GraphicStyle(lineThickness, colorAccent, false, colorControlBackground);
    }

    GraphicStyle defaultStyle(GraphicStyle* ownStyle)
    {
        if (ownStyle)
        {
            return *ownStyle;
        }
        return defaultStyle();
    }

    GraphicStyle defaultStyle()
    {
        GraphicStyle style = GraphicStyle(lineThickness, colorAccent, false, colorControlBackground);
        return style;
    }

    //TODO @safe
    Sprite2d background(float width, float height, float angle, scope GraphicStyle* parentStyle = null)
    {
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        GraphicStyle backgroundStyle = parentStyle ? *parentStyle : GraphicStyle(
            lineThickness, colorAccent, true, colorControlBackground);

        return shape(width, height, angle, backgroundStyle);
    }

    Sprite2d shape(float width, float height, float angle, GraphicStyle style)
    {
        return convexPolyShape(width, height, angle, controlCornersBevel, style);
    }

    Sprite2d convexPolyShape(float width, float height, float angle, float cornerBevel, GraphicStyle style)
    {
        Sprite2d newShape;
        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.shapes.vec_convex_poly : VecConvexPoly;

            newShape = new VecConvexPoly(width, height, style, cornerBevel);
        }
        else
        {
            //if (style.isFill)
            //{
            return rectShape(width, height, angle, style);
            // }

            //import api.dm.kit.sprites2d.shapes.convex_polygon : ConvexPolygon;

            //newShape = new ConvexPolygon(width, height, style, cornerBevel);
        }

        newShape.angle = angle;
        return newShape;
    }

    Sprite2d rectShape(float width, float height, float angle, GraphicStyle style)
    {
        Sprite2d shape;
        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.shapes.vec_rectangle : VecRectangle;

            shape = new VecRectangle(width, height, style);
        }
        else
        {
            import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;

            shape = new Rectangle(width, height, style);
        }
        shape.angle = angle;
        return shape;
    }

    Sprite2d circleShape(GraphicStyle style) => circleShape(roundShapeDiameter, style);

    Sprite2d circleShape(float diameter, GraphicStyle style)
    {
        float radius = diameter / 2;

        Sprite2d shape;
        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.shapes.vec_circle : VecCircle;

            shape = new VecCircle(radius, style);
        }
        else
        {
            import api.dm.kit.sprites2d.shapes.circle : Circle;

            shape = new Circle(radius, style);
        }
        return shape;
    }

    Sprite2d regularPolyShape(float angle, GraphicStyle style) => regularPolyShape(
        regularPolyDiameter, regularPolySides, angle, style);

    Sprite2d regularPolyShape(float size, size_t sides, float angle, GraphicStyle style)
    {
        Sprite2d shape;

        import Math = api.math;

        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.shapes.vec_regular_poly : VecRegularPoly;

            shape = new VecRegularPoly(size, style, sides);
        }
        else
        {
            import api.dm.kit.sprites2d.shapes.reqular_polygon : RegularPolygon;

            shape = new RegularPolygon(size, style, sides);
        }

        shape.angle = angle;

        return shape;
    }

    Sprite2d triangleShape(float width, float height, float angleDeg, GraphicStyle style)
    {

        Sprite2d shape;

        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.shapes.vec_triangle : VecTriangle;

            shape = new VecTriangle(width, height, style);
        }
        else
        {
            import api.dm.kit.sprites2d.shapes.triangle : Triangle;

            shape = new Triangle(width, height, style);
        }

        assert(shape);
        shape.angle = angleDeg;
        return shape;
    }

}
