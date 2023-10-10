module deltotum.kit.assets.fonts.font;

import deltotum.core.apps.units.services.loggable_unit : LoggableUnit;
import deltotum.kit.graphics.colors.rgba : RGBA;

import deltotum.sys.sdl.ttf.sdl_ttf_font : SdlTTFFont;
import deltotum.sys.sdl.sdl_surface : SdlSurface;
import deltotum.sys.sdl.sdl_texture : SdlTexture;

import std.logger.core : Logger;
import std.string : toStringz;

/**
 * Authors: initkfs
 */
class Font : LoggableUnit
{
    //private
    //{
        SdlTTFFont font;

        string fontPath;
        int fontSize;
    //}

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

    SdlSurface renderSurface(const char* text, RGBA color = RGBA.white, RGBA background = RGBA.black)
    {
        SdlSurface fontSurface = new SdlSurface;
        if (const fontRenderErr = font.render(fontSurface, text, color.r, color.g, color.b, color
                .aNorm, background.r, background.g, background.b))
        {
            logger.error(fontRenderErr.toString);
            if(const err = fontSurface.createRGBSurface){
                throw new Exception(err.toString);
            }
            return fontSurface;
        }

        if (fontSurface.isEmpty)
        {
            import std.string : fromStringz;

            logger.errorf("Received empty surface for text: %s", text.fromStringz.idup);
            if(const err = fontSurface.createRGBSurface){
                throw new Exception(err.toString);
            }
            return fontSurface;
        }

        return fontSurface;
    }

    override void dispose()
    {
        super.dispose;
        if (font !is null)
        {
            font.dispose;
        }
    }
}
