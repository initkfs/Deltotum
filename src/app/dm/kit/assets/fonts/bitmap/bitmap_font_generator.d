module app.dm.kit.assets.fonts.bitmap.bitmap_font_generator;

import app.dm.com.graphics.com_font : ComFontHinting, ComFont;
import app.dm.com.graphics.com_surface : ComSurface;
import app.dm.kit.assets.fonts.font_generator : FontGenerator;
import app.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import app.core.utils.factories : Provider;

import app.dm.kit.assets.fonts.font : Font;
import app.dm.kit.sprites.textures.texture : Texture;
import app.dm.kit.graphics.colors.rgba : RGBA;

import app.dm.kit.assets.fonts.bitmap.bitmap_font : BitmapFont;
import app.dm.kit.i18n.langs.alphabets.alphabet : Alphabet;
import app.dm.math.rect2d : Rect2d;
import app.dm.math.vector2 : Vector2;

import std.string : toStringz;
import std.uni : byGrapheme;
import std.utf : toUTFz;
import std.stdio;

/**
 * Authors: initkfs
 */
class BitmapFontGenerator : FontGenerator
{
    Provider!ComSurface comSurfaceProvider;

    //TODO correct size?
    enum size_t defaultFontTextureWidth = 400;
    enum size_t defaultFontTextureHeight = 400;

    this(Provider!ComSurface comSurfaceProvider)
    {
        this.comSurfaceProvider = comSurfaceProvider;
    }

    BitmapFont generate(
        Alphabet[] alphabets, 
        Font font, 
        RGBA foregroundColor = RGBA.white, 
        RGBA backgroundColor = RGBA.black, 
        int  fontTextureWidth = defaultFontTextureWidth, 
        int fontTextureHeight = defaultFontTextureWidth
        )
    {
        assert(fontTextureWidth > 0);
        assert(fontTextureHeight > 0);
        
        //The size can be very large to create on a stack
        ComSurface fontMapSurface = comSurfaceProvider.getNew();
        if (const err = fontMapSurface.createRGB(fontTextureWidth, fontTextureHeight))
        {
            throw new Exception(err.toString);
        }

        //TODO background
        //SDL_SetColorKey(fontMapSurface.getObject, SDL_TRUE, SDL_MapRGBA(
        //        fontMapSurface.getObject.format, 0, 0, 0, 0));
        if (const err = fontMapSurface.setPixelIsTransparent(true, 0, 0, 0, 0))
        {
            throw new Exception(err.toString);
        }

        Rect2d glyphPosition;
        Glyph[] glyphs;

        font.setHinting(ComFontHinting.normal);

        auto bitmapFont = new BitmapFont;
        build(bitmapFont);
        bitmapFont.initialize;
        assert(bitmapFont.isInitialized);

        foreach (alphabet; alphabets)
        {
            dstring allLetters = alphabet.allLetters;
            //TODO byGrapheme?
            foreach (i, dchar letter; allLetters)
            {
                const(dchar[1]) letters = [letter];
                //TODO does SDL keep a reference?
                comSurfaceProvider.getNewScoped((glyphRepresentation) {
                    font.renderSurface(glyphRepresentation, letters[], foregroundColor, backgroundColor);
                    int w, h;
                    if (auto err = glyphRepresentation.getWidth(w))
                    {
                        throw new Exception(err.toString);
                    }
                    if (auto err = glyphRepresentation.getHeight(h))
                    {
                        throw new Exception(err.toString);
                    }

                    glyphPosition.width = w;
                    glyphPosition.height = h;

                    if (glyphPosition.x + glyphPosition.width >= fontTextureWidth)
                    {
                        glyphPosition.x = 0;

                        glyphPosition.y += glyphPosition.height + 1;

                        if (glyphPosition.y + glyphPosition.height >= fontTextureWidth)
                        {
                            throw new Exception("Font creation error, texture size too small");
                        }
                    }

                    //TODO special?
                    import std.uni : isWhite;
                    import std.algorithm.comparison : among;

                    bool isNewline;
                    bool isEmpty = letter.isWhite;
                    if (isEmpty)
                    {
                        //FIXME \r\n
                        isNewline = letter.among('\n', '\r',) != 0;
                    }

                    auto glyph = Glyph(letter, glyphPosition, Vector2.init, alphabet, isEmpty, isNewline);

                    //TODO config?
                    if (glyph.grapheme == '𑑛')
                    {
                        bitmapFont.placeholder = glyph;
                    }

                    glyphs ~= glyph;

                    if (const err = glyphRepresentation.blit(fontMapSurface, glyphPosition))
                    {
                        throw new Exception(err.toString);
                    }
                    glyphRepresentation.dispose;
                });

                glyphPosition.x += glyphPosition.width;
            }
        }

        bitmapFont.glyphs = glyphs;

        bitmapFont.loadFromSurface(fontMapSurface);
        fontMapSurface.dispose;

        bitmapFont.create;

        bitmapFont.blendModeBlend;

        return bitmapFont;
    }
}
