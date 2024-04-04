module dm.kit.assets.fonts.font;

import dm.core.components.units.services.loggable_unit : LoggableUnit;
import dm.kit.graphics.colors.rgba : RGBA;

import dm.com.graphics.com_font : ComFont, ComFontHinting;
import dm.com.graphics.com_surface : ComSurface;
import dm.com.graphics.com_texture : ComTexture;

import std.logger.core : Logger;
import std.string : toStringz;

/**
 * Authors: initkfs
 */
class Font : LoggableUnit
{
    private
    {
        ComFont font;
    }

    this(Logger logger, ComFont font)
    {
        super(logger);
        this.font = font;
    }

    void renderSurface(ComSurface surf, string text, RGBA color = RGBA.white)
    {
        return renderSurface(surf, text.toStringz, color);
    }

    void renderSurface(ComSurface fontSurface, const char* text, RGBA color = RGBA.white, RGBA background = RGBA
            .black)
    {
        if (const fontRenderErr = font.renderFont(fontSurface, text, color.r, color.g, color.b, color
                .aByte, background.r, background.g, background.b, background.aByte))
        {
            logger.error(fontRenderErr.toString);
        }

        int w, h;
        if (const err = fontSurface.getWidth(w))
        {
            logger.error(err.toString);
        }

        if (const err = fontSurface.getHeight(h))
        {
            logger.error(err.toString);
        }

        if (w == 0 && h == 0)
        {
            import std.string : fromStringz;

            logger.errorf("Received empty surface for text: %s", text.fromStringz.idup);
        }
    }

    string fontPath()
    {
        string path;
        if (const err = font.getFontPath(path))
        {
            logger.error("Font path error. ", err);
        }
        return path;
    }

    size_t fonSize()
    {
        size_t size;
        if (const err = font.getFontSize(size))
        {
            logger.error("Font size error. ", err);
        }
        return size;
    }

    void setHinting(ComFontHinting hinting)
    {
        if (const err = font.setHinting(hinting))
        {
            logger.error("Hinting error. ", err);
        }
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
