module api.dm.gui.themes.theme;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.com.graphics.com_font : ComFont;
import api.math.pos2.insets : Insets;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.icons.icon_pack : IconPack;
import api.dm.kit.sprites2d.images.image : Image;
import api.dm.kit.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.core.configs.uda : ConfigKey;

import std.typecons : Nullable;
import api.dm.kit.sprites2d.textures.vectors.shapes.vrectangle;

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
    float opacityContainers = 1;
    @ConfigKey
    float opacityControls = 1;
    @ConfigKey
    float opacityBackground = 0.85;
    @ConfigKey
    float opacityHover = 1;

    @ConfigKey
    size_t iconSize = 24;

    @ConfigKey
    int lineThickness = 3;

    Insets controlPadding = Insets(5, 5, 5, 5);
    float controlSpacing = 5;
    float controlCornersBevel = 8;
    GraphicStyle controlStyle = GraphicStyle.simple;

    @ConfigKey
    float controlDefaultWidth = 100;
    @ConfigKey
    float controlDefaultHeight = 80;
    @ConfigKey
    float controlGraphicsGap = 5;

    @ConfigKey
    float layoutIndent = 0;

    @ConfigKey
    float buttonWidth = 80;
    @ConfigKey
    float buttonHeight = 30;
    @ConfigKey
    float roundShapeDiameter = 20;
    @ConfigKey
    float regularPolyDiameter = 80;
    @ConfigKey
    size_t regularPolySides = 8;
    @ConfigKey
    float parallelogramShapeAngleDeg = 15;

    bool isUseVectorGraphics;

    @ConfigKey
    size_t actionEffectAnimationDelayMs;
    @ConfigKey
    size_t hoverAnimationDelayMs;
    @ConfigKey
    size_t popupDelayMs;

    @ConfigKey
    float checkMarkerWidth = 30;
    @ConfigKey
    float checkMarkerHeight = 30;

    @ConfigKey
    float toggleSwitchMarkerWidth = 30;
    @ConfigKey
    float toggleSwitchMarkerHeight = 30;

    @ConfigKey
    float separatorHeight = 5;

    @ConfigKey
    float meterThumbWidth = 30;
    @ConfigKey
    float meterThumbHeight = 30;
    @ConfigKey
    float meterThumbDiameter = 60;

    @ConfigKey
    float meterTickMinorWidth = 2;
    @ConfigKey
    float meterTickMinorHeight = 3;
    @ConfigKey
    float meterTickMajorWidth = 2;
    @ConfigKey
    float meterTickMajorHeight = 5;
    @ConfigKey
    float meterHandWidth = 5;

    @ConfigKey
    float loaderSize = 50;

    @ConfigKey
    float dividerSize = 2;

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

        Sprite2d newBackground;
        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

            newBackground = new VConvexPolygon(width, height, backgroundStyle, controlCornersBevel);
        }
        else
        {
            import api.dm.kit.sprites2d.shapes.convex_polygon : ConvexPolygon;

            backgroundStyle.lineWidth = 1.0;

            newBackground = new ConvexPolygon(width, height, backgroundStyle, controlCornersBevel);
        }

        newBackground.angle = angle;

        return newBackground;
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
            import api.dm.kit.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

            newShape = new VConvexPolygon(width, height, style, cornerBevel);
        }
        else
        {
            import api.dm.kit.sprites2d.shapes.convex_polygon : ConvexPolygon;

            newShape = new ConvexPolygon(width, height, style, cornerBevel);
        }

        newShape.angle = angle;
        return newShape;
    }

    Sprite2d rectShape(float width, float height, float angle, GraphicStyle style)
    {
        Sprite2d shape;
        if (isUseVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.shapes.vrectangle : VRectangle;

            shape = new VRectangle(width, height, style);
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
            import api.dm.kit.sprites2d.textures.vectors.shapes.vcircle : VCircle;

            shape = new VCircle(radius, style);
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
            import api.dm.kit.sprites2d.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

            shape = new VRegularPolygon(size, style, sides);
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
            import api.dm.kit.sprites2d.textures.vectors.shapes.vtriangle : VTriangle;

            shape = new VTriangle(width, height, style);
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
