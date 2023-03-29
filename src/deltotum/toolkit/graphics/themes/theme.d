module deltotum.toolkit.graphics.themes.theme;

import deltotum.toolkit.graphics.colors.rgba : RGBA;
import deltotum.toolkit.asset.fonts.font: Font;
import deltotum.maths.geometry.insets: Insets;
import deltotum.toolkit.graphics.styles.graphic_style: GraphicStyle;

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

    RGBA colorBackground(){
        return RGBA.blue;
    }

    double controlOpacity(){
        return 0.8;
    }

    double controlHoverOpacity(){
        return 0.4;
    }

    RGBA controlBackground(){
        return RGBA.red;
    }

    Insets controlPadding(){
        return Insets(5);
    }

    GraphicStyle controlStyle(){
        return GraphicStyle.simple;
    }
}
