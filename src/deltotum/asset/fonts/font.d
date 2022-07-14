module deltotum.asset.fonts.font;

import deltotum.hal.sdl.ttf.sdl_ttf_font : SdlTTFFont;

//TODO remove HAL api
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Font
{
    private
    {
        SdlTTFFont font;

        string fontPath;
        int fontSize;
    }

    this(string fontPath, int fontSize = 12)
    {
        //TODO validate
        this.fontPath = fontPath;
        this.fontSize = fontSize;

        //TODO or load()?
        font = new SdlTTFFont(fontPath, fontSize);
    }

    void destroy()
    {
        if (font !is null)
        {
            font.destroy;
        }
    }

    TTF_Font* getStruct()
    {
        return font.getStruct;
    }

}
