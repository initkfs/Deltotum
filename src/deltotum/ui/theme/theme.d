module deltotum.ui.theme.theme;

import deltotum.graphics.colors.color : Color;
import deltotum.asset.fonts.font: Font;

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
        return Color.blue;
    }

    Color colorSecondary()
    {
        return Color.green;
    }

    Color colorAccent()
    {
        return Color.red;
    }

    Color hoverColor()
    {
        return Color.white;
    }
}
