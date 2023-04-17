module deltotum.toolkit.graphics.themes.theme;

import deltotum.toolkit.graphics.colors.rgba : RGBA;
import deltotum.toolkit.asset.fonts.font : Font;
import deltotum.maths.geometry.insets : Insets;
import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class Theme
{
    private
    {
        Font defaultMediumFont;
    }

    RGBA colorPrimary = RGBA.black;
    RGBA colorSecondary = RGBA.green;
    RGBA colorAccent = RGBA.white;
    RGBA colorFocus = RGBA.red;
    RGBA colorText = RGBA.white;
    RGBA colorHover = RGBA.white;

    RGBA colorControlBackground = RGBA.black;
    RGBA colorContainerBackground = RGBA.black;

    double opacityContainers = 1;
    double opacityControls = 1;
    double opacityHover = 1;

    Insets controlPadding = Insets(5, 5, 5, 5);
    double controlCornersBevel = 8;
    GraphicStyle controlStyle = GraphicStyle.simple;

    this(Font defaultMediumFont)
    {
        this.defaultMediumFont = defaultMediumFont;
    }

    Font defaultFontMedium()
    {
        return defaultMediumFont;
    }
}
