module api.dm.gui.themes.theme;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.assets.fonts.font : Font;
import api.math.insets : Insets;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.themes.icons.icon_pack : IconPack;
import api.dm.kit.sprites.images.image : Image;
import api.dm.kit.sprites.shapes.shape : Shape;
import api.dm.kit.sprites.sprite : Sprite;
import api.core.configs.uda: ConfigKey;

import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class Theme
{
    private
    {
        Font _defaultMediumFont;
        IconPack iconPack;
    }

    @ConfigKey
    RGBA colorPrimary = RGBA.black;
    @ConfigKey
    RGBA colorSecondary = RGBA.green;
    @ConfigKey
    RGBA colorAccent = RGBA.white;

    @ConfigKey
    RGBA colorFocus = RGBA.red;
    @ConfigKey
    RGBA colorText = RGBA.white;
    @ConfigKey
    RGBA colorTextBackground = RGBA.black;
    @ConfigKey
    RGBA colorHover = RGBA.white;

    @ConfigKey
    RGBA colorSuccess = RGBA(72, 199, 116);
    @ConfigKey
    RGBA colorDanger = RGBA(255, 56, 96);
    @ConfigKey
    RGBA colorWarning = RGBA(255, 221, 87);

    @ConfigKey
    RGBA colorControlBackground = RGBA.black;
    @ConfigKey
    RGBA colorContainerBackground = RGBA.black;

    @ConfigKey
    double opacityContainers = 1;
    @ConfigKey
    double opacityControls = 1;
    @ConfigKey
    double opacityBackground = 0.85;
    @ConfigKey
    double opacityHover = 1;

    @ConfigKey
    size_t iconSize = 24;

    @ConfigKey
    int lineThickness = 3;

    Insets controlPadding = Insets(5, 5, 5, 5);
    double controlSpacing = 5;
    double controlCornersBevel = 8;
    GraphicStyle controlStyle = GraphicStyle.simple;

    @ConfigKey
    double controlDefaultWidth = 100;
    @ConfigKey
    double controlDefaultHeight = 80;
    @ConfigKey
    double controlGraphicsGap = 5;

    @ConfigKey
    double buttonWidth = 80;
    @ConfigKey
    double buttonHeight = 30;
    @ConfigKey
    double roundShapeDiameter = 20;
    @ConfigKey
    double regularPolyDiameter = 80;
    @ConfigKey
    size_t regularPolySides = 8;
    @ConfigKey
    double parallelogramShapeAngleDeg = 15;

    bool isUseVectorGraphics;

    @ConfigKey
    size_t actionAnimationDelayMs;
    @ConfigKey
    size_t hoverAnimationDelayMs;
    @ConfigKey
    size_t tooltipDelayMs;

    this(IconPack iconPack)
    {
        this.iconPack = iconPack;
    }

    void defaultMediumFont(Font font)
    {
        assert(font);
        _defaultMediumFont = font;
    }

    Font defaultMediumFont()
    {
        assert(_defaultMediumFont, "Default medium font is null");
        return _defaultMediumFont;
    }

    Nullable!string iconData(string id)
    {
        if (!iconPack)
        {
            return Nullable!(string).init;
        }
        Nullable!string data = iconPack.icon(id);
        return data;
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
    Sprite background(double width, double height, scope GraphicStyle* parentStyle = null)
    {
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        GraphicStyle backgroundStyle = parentStyle ? *parentStyle : GraphicStyle(
            lineThickness, colorAccent, true, colorControlBackground);

        Sprite newBackground;
        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

            newBackground = new VConvexPolygon(width, height, backgroundStyle, controlCornersBevel);
        }
        else
        {
            import api.dm.kit.sprites.shapes.convex_polygon : ConvexPolygon;

            backgroundStyle.lineWidth = 1.0;

            newBackground = new ConvexPolygon(width, height, backgroundStyle, controlCornersBevel);
        }
        return newBackground;
    }

    Sprite roundShape(GraphicStyle style) => roundShape(roundShapeDiameter, style);

    Sprite roundShape(double diameter, GraphicStyle style)
    {
        double radius = diameter / 2;

        Sprite shape;
        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites.textures.vectors.shapes.vcircle : VCircle;

            shape = new VCircle(radius, style);
        }
        else
        {
            import api.dm.kit.sprites.shapes.circle : Circle;

            shape = new Circle(radius, style);
        }
        return shape;
    }

    Sprite regularPolyShape(GraphicStyle style) => regularPolyShape(regularPolyDiameter, regularPolySides, style);

    Sprite regularPolyShape(double size, size_t sides, GraphicStyle style)
    {
        Sprite shape;

        import Math = api.math;

        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

            shape = new VRegularPolygon(size, style, sides);
        }
        else
        {
            import api.dm.kit.sprites.shapes.reqular_polygon : RegularPolygon;

            shape = new RegularPolygon(size, style, sides);
        }
        return shape;
    }

}
