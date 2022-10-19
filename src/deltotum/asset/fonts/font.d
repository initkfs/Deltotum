module deltotum.asset.fonts.font;

import deltotum.application.components.uni.uni_component;

import deltotum.hal.sdl.ttf.sdl_ttf_font : SdlTTFFont;
import deltotum.graphics.colors.color : Color;
import deltotum.hal.sdl.sdl_surface : SdlSurface;
import deltotum.hal.sdl.sdl_texture : SdlTexture;

import std.string: toStringz;

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

    SdlSurface renderSurface(string text, Color color = Color.white)
    {
        return renderSurface(text.toStringz, color);
    }

    SdlSurface renderSurface(const char* text, Color color = Color.white)
    {
        SdlSurface fontSurface = new SdlSurface;
        if (const fontRenderErr = font.render(fontSurface, text, color.r, color.g, color.b, color
                .alphaNorm))
        {
            //TODO logging?
            throw new Exception(fontRenderErr.toString);
        }

        if (fontSurface.isEmpty)
        {
            //TODO logging?
            throw new Exception("Font surface is empty");
        }

        return fontSurface;
    }

    void destroy()
    {
        if (font !is null)
        {
            font.destroy;
        }
    }
}
