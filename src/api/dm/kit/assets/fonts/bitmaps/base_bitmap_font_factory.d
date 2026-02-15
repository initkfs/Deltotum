module api.dm.kit.assets.fonts.bitmaps.base_bitmap_font_factory;

import api.dm.kit.components.graphic_component : GraphicComponent;
import api.dm.com.graphics.com_font : ComFont;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;

import api.dm.kit.graphics.colors.rgba : RGBA;

import api.dm.kit.assets.fonts.bitmaps.bitmap_font : BitmapFont;
import api.math.geom2.rect2 : Rect2f;
import api.math.geom2.vec2 : Vec2f;

import Math = api.math;

/**
 * Authors: initkfs
 */
class BaseBitmapFontFactory : GraphicComponent
{
    //TODO correct size?
    enum size_t defaultFontTextureWidth = 400;
    enum size_t defaultFontTextureHeight = 400;

    void generateToSurface(
        const(dchar)[] allLetters,
        ComSurface fontMapSurface,
        ComFont font,
        scope void delegate(ref Glyph, ref Rect2f pos) onGlyphPos,
        RGBA foregroundColor = RGBA.white,
        RGBA backgroundColor = RGBA.black,
        ref Rect2f glyphPosition
    )
    {
        foreach (i, dchar letter; allLetters)
        {
            dchar[1] letters = [letter];
            //TODO does SDL keep a reference?
            graphic.comSurfaceProvider.getNewScoped((glyphRepresentation) {

                const isErr = font.renderFont(glyphRepresentation, letters[], foregroundColor.r, foregroundColor.g, foregroundColor
                    .b, foregroundColor
                    .aByte, backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor
                    .aByte);

                if (isErr)
                {
                    throw new Exception(isErr.toString);
                }

                glyphPosition.width = glyphRepresentation.getWidth;
                glyphPosition.height = glyphRepresentation.getHeight;

                if (glyphPosition.x + glyphPosition.width >= fontMapSurface.getWidth)
                {
                    glyphPosition.x = 0;

                    glyphPosition.y += glyphPosition.height + 1;

                    if (glyphPosition.y + glyphPosition.height >= fontMapSurface.getHeight)
                    {
                        throw new Exception("Font FactoryKit error, texture size too small");
                    }
                }

                auto glyph = Glyph(letter, glyphPosition, Vec2f.init);
                onGlyphPos(glyph, glyphPosition);

                if (const err = glyphRepresentation.copyTo(fontMapSurface, glyphPosition))
                {
                    throw new Exception(err.toString);
                }
                glyphRepresentation.dispose;
            });

            glyphPosition.x += glyphPosition.width;
        }
    }

    BitmapFont newBitmapFont()
    {
        auto bitmapFont = new BitmapFont;
        buildInit(bitmapFont);

        return bitmapFont;
    }

    ComSurface newFontSurface(ComFont font, int fontTextureWidth = defaultFontTextureWidth,
        int fontTextureHeight = defaultFontTextureWidth)
    {
        ComSurface fontMapSurface = graphic.comSurfaceProvider.getNew();
        if (const err = fontMapSurface.createRGBA32(fontTextureWidth, fontTextureHeight))
        {
            throw new Exception(err.toString);
        }

        if (const err = fontMapSurface.setPixelIsTransparent(true, 0, 0, 0, 0))
        {
            throw new Exception(err.toString);
        }

        return fontMapSurface;
    }
}
