module deltotum.graphics.themes.theme;

import deltotum.graphics.colors.color : Color;
import deltotum.asset.fonts.font: Font;
import deltotum.display.padding: Padding;

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

    Color colorPrimary()
    {
        //gray 700
        return Color(97, 97, 97);
    }

    Color colorSecondary()
    {
        //gray 500
        return Color(158, 158, 158);
    }

    Color colorAccent()
    {
        //gray 200
        return Color(238, 238, 238);
    }

    Color colorHover()
    {
        //gray 400
        return Color(189, 189, 189);
    }

    double controlOpacity(){
        return 0.5;
    }

    Padding controlPadding(){
        return Padding(5);
    }
}
