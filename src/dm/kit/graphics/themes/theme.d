module dm.kit.graphics.themes.theme;

import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.assets.fonts.font : Font;
import dm.math.geom.insets : Insets;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.kit.graphics.themes.icons.icon_pack : IconPack;
import dm.kit.sprites.images.image : Image;
import dm.kit.sprites.shapes.shape : Shape;
import dm.kit.sprites.sprite : Sprite;

import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class Theme
{
    private
    {
        Font defaultMediumFont;
        IconPack iconPack;
    }

    RGBA colorPrimary = RGBA.black;
    RGBA colorSecondary = RGBA.green;
    RGBA colorAccent = RGBA.white;

    RGBA colorFocus = RGBA.red;
    RGBA colorText = RGBA.white;
    RGBA colorTextBackground = RGBA.black;
    RGBA colorHover = RGBA.white;

    RGBA colorSuccess = RGBA(72, 199, 116);
    RGBA colorDanger = RGBA(255, 56, 96);
    RGBA colorWarning = RGBA(255, 221, 87);

    RGBA colorControlBackground = RGBA.black;
    RGBA colorContainerBackground = RGBA.black;

    double opacityContainers = 1;
    double opacityControls = 1;
    double opacityHover = 1;

    size_t iconSize = 24;

    bool isUseVectorGraphics;
    int lineThickness = 3;

    Insets controlPadding = Insets(5, 5, 5, 5);
    double controlSpacing = 5;
    double controlCornersBevel = 8;
    GraphicStyle controlStyle = GraphicStyle.simple;

    this(Font defaultMediumFont, IconPack iconPack)
    {
        this.defaultMediumFont = defaultMediumFont;
        this.iconPack = iconPack;
    }

    Font fontMedium()
    {
        return defaultMediumFont;
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

    GraphicStyle defaultStyle()
    {
        GraphicStyle style = GraphicStyle(lineThickness, colorAccent, false, colorControlBackground);
        return style;
    }

    //TODO @safe
    Sprite background(double width, double height, scope GraphicStyle* parentStyle = null)
    {
        import dm.kit.graphics.styles.graphic_style : GraphicStyle;

        GraphicStyle backgroundStyle = parentStyle ? *parentStyle : GraphicStyle(
            lineThickness, colorAccent, false, colorControlBackground);

        Sprite newBackground;
        if (isUseVectorGraphics)
        {
            import dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

            newBackground = new VRegularPolygon(width, height, backgroundStyle, controlCornersBevel);
        }
        else
        {
            import dm.kit.sprites.shapes.regular_polygon : RegularPolygon;

            backgroundStyle.lineWidth = 1.0;

            newBackground = new RegularPolygon(width, height, backgroundStyle, controlCornersBevel);
        }
        return newBackground;
    }

}
