module deltotum.toolkit.graphics.themes.theme;

import deltotum.toolkit.graphics.colors.rgba : RGBA;
import deltotum.toolkit.asset.fonts.font: Font;
import deltotum.toolkit.display.padding: Padding;

/**
 * Authors: initkfs
 */
class Theme
{
    private {
        Font defaultMediumFont;
    }

    this(Font defaultMediumFont){
        this.defaultMediumFont = defaultMediumFont;
    }

    Font defaultFontMedium(){
        return defaultMediumFont;
    }

    RGBA colorPrimary()
    {
        //gray 700
        return RGBA(97, 97, 97);
    }

    RGBA colorSecondary()
    {
        //gray 500
        return RGBA(158, 158, 158);
    }

    RGBA colorAccent()
    {
        //gray 200
        return RGBA(238, 238, 238);
    }

    RGBA colorHover()
    {
        //gray 400
        return RGBA(189, 189, 189);
    }

    double controlOpacity(){
        return 0.5;
    }

    Padding controlPadding(){
        return Padding(5);
    }
}
