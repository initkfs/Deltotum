module dm.kit.graphics.themes.theme;

import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.assets.fonts.font : Font;
import dm.math.geom.insets : Insets;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.kit.graphics.themes.icons.icon_pack : IconPack;
import dm.kit.sprites.images.image : Image;

import std.typecons: Nullable;

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
    RGBA colorWarning= RGBA(255, 221, 87);

    RGBA colorControlBackground = RGBA.black;
    RGBA colorContainerBackground = RGBA.black;

    double opacityContainers = 1;
    double opacityControls = 1;
    double opacityHover = 1;

    size_t iconSize = 24;

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
        if(!iconPack){
            return Nullable!(string).init;
        }
        Nullable!string data = iconPack.icon(id);
        return data;
    }

}
