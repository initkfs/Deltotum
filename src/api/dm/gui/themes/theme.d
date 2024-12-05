module api.dm.gui.themes.theme;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.assets.fonts.font : Font;
import api.math.insets : Insets;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.themes.icons.icon_pack : IconPack;
import api.dm.kit.sprites.sprites2d.images.image : Image;
import api.dm.kit.sprites.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.core.configs.uda : ConfigKey;

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
    double layoutIndent = 0;

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
    size_t actionEffectAnimationDelayMs;
    @ConfigKey
    size_t hoverAnimationDelayMs;
    @ConfigKey
    size_t tooltipDelayMs;

    @ConfigKey
    double checkMarkerWidth = 30;
    @ConfigKey
    double checkMarkerHeight = 30;

    @ConfigKey
    double toggleSwitchMarkerWidth = 30;
    @ConfigKey
    double toggleSwitchMarkerHeight = 30;

    @ConfigKey
    double separatorHeight = 5;

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
    Sprite2d background(double width, double height, double angle, scope GraphicStyle* parentStyle = null)
    {
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        GraphicStyle backgroundStyle = parentStyle ? *parentStyle : GraphicStyle(
            lineThickness, colorAccent, true, colorControlBackground);

        Sprite2d newBackground;
        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

            newBackground = new VConvexPolygon(width, height, backgroundStyle, controlCornersBevel);
        }
        else
        {
            import api.dm.kit.sprites.sprites2d.shapes.convex_polygon : ConvexPolygon;

            backgroundStyle.lineWidth = 1.0;

            newBackground = new ConvexPolygon(width, height, backgroundStyle, controlCornersBevel);
        }

        newBackground.angle = angle;

        return newBackground;
    }

    Sprite2d shape(double width, double height, double angle, GraphicStyle style)
    {
        return convexPolyShape(width, height, angle, controlCornersBevel, style);
    }

    Sprite2d convexPolyShape(double width, double height, double angle, double cornerBevel, GraphicStyle style)
    {
        Sprite2d newShape;
        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

            newShape = new VConvexPolygon(width, height, style, cornerBevel);
        }
        else
        {
            import api.dm.kit.sprites.sprites2d.shapes.convex_polygon : ConvexPolygon;

            newShape = new ConvexPolygon(width, height, style, cornerBevel);
        }

        newShape.angle = angle;
        return newShape;
    }

    Sprite2d rectShape(double width, double height, double angle, GraphicStyle style)
    {
        return convexPolyShape(width, height, angle, 0, style);
    }

    Sprite2d roundShape(GraphicStyle style) => roundShape(roundShapeDiameter, style);

    Sprite2d roundShape(double diameter, GraphicStyle style)
    {
        double radius = diameter / 2;

        Sprite2d shape;
        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vcircle : VCircle;

            shape = new VCircle(radius, style);
        }
        else
        {
            import api.dm.kit.sprites.sprites2d.shapes.circle : Circle;

            shape = new Circle(radius, style);
        }
        return shape;
    }

    Sprite2d regularPolyShape(double angle, GraphicStyle style) => regularPolyShape(
        regularPolyDiameter, regularPolySides, angle, style);

    Sprite2d regularPolyShape(double size, size_t sides, double angle, GraphicStyle style)
    {
        Sprite2d shape;

        import Math = api.math;

        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

            shape = new VRegularPolygon(size, style, sides);
        }
        else
        {
            import api.dm.kit.sprites.sprites2d.shapes.reqular_polygon : RegularPolygon;

            shape = new RegularPolygon(size, style, sides);
        }

        shape.angle = angle;

        return shape;
    }

    Sprite2d triangleShape(double width, double height, double angleDeg, GraphicStyle style)
    {

        Sprite2d shape;

        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vtriangle : VTriangle;

            shape = new VTriangle(width, height, style);
        }
        else
        {
            import api.dm.kit.sprites.sprites2d.shapes.triangle : Triangle;

            shape = new Triangle(width, height, style);
        }

        assert(shape);
        shape.angle = angleDeg;
        return shape;
    }

}
