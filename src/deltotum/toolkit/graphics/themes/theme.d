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
        //rgb(12, 51, 84)
        return RGBA(12, 51, 84);
    }

    RGBA colorSecondary()
    {
        //rgb(5, 91, 148)
        return RGBA(5, 91, 148);
    }

    RGBA colorAccent()
    {
        //#06E1F4
        //rgb(6, 225, 244)
        return RGBA(6, 225, 244);
    }

    RGBA colorText(){
        return colorAccent;
    }

    RGBA colorHover()
    {
        //return RGBA(195, 250, 255);
        return colorSecondary;
    }

    RGBA colorFocus(){
        return RGBA.red;
    }

    double controlOpacity(){
        return 0.8;
    }

    double controlHoverOpacity(){
        return 0.4;
    }

    RGBA colorContainerBackground(){
        return colorPrimary;
    }

    RGBA colorControlBackground(){
        return colorSecondary;
    }

    double opacityContainer(){
        return 0.9;
    }

    double opacityControl(){
        return 0.75;
    }

    Insets controlPadding(){
        return Insets(5);
    }

    GraphicStyle controlStyle(){
        return GraphicStyle.simple;
    }

    double cornersBevel(){
        return 8;
    }
}
