module deltotum.asset.fonts.font;

import deltotum.application.components.units.service.loggable_unit : LoggableUnit;
import deltotum.graphics.colors.rgba : RGBA;

import deltotum.hal.sdl.ttf.sdl_ttf_font : SdlTTFFont;
import deltotum.hal.sdl.sdl_surface : SdlSurface;
import deltotum.hal.sdl.sdl_texture : SdlTexture;

import std.experimental.logger.core : Logger;
import std.string : toStringz;

/**
 * Authors: initkfs
 */
class Font : LoggableUnit
{
    private
    {
        SdlTTFFont font;

        string fontPath;
        int fontSize;
    }

    this(Logger logger, string fontPath, int fontSize = 12)
    {
        super(logger);
        //TODO validate
        this.fontPath = fontPath;
        this.fontSize = fontSize;

        //TODO or load()?
        font = new SdlTTFFont(fontPath, fontSize);
    }

    SdlSurface renderSurface(string text, RGBA color = RGBA.white)
    {
        return renderSurface(text.toStringz, color);
    }

    SdlSurface renderSurface(const char* text, RGBA color = RGBA.white)
    {
        SdlSurface fontSurface = new SdlSurface;
        if (const fontRenderErr = font.render(fontSurface, text, color.r, color.g, color.b, color
                .alphaNorm))
        {
            logger.error(fontRenderErr.toString);
            fontSurface.createRGBSurface;
            return fontSurface;
        }

        if (fontSurface.isEmpty)
        {
            import std.string : fromStringz;

            logger.errorf("Received empty surface for text: %s", text.fromStringz.idup);
            fontSurface.createRGBSurface;
            return fontSurface;
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
