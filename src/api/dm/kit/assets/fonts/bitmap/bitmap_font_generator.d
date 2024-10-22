module api.dm.kit.assets.fonts.bitmap.bitmap_font_generator;

import api.dm.com.graphics.com_font : ComFontHinting, ComFont;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.kit.assets.fonts.font_generator : FontGenerator;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import api.core.utils.factories : Provider;

import api.dm.kit.assets.fonts.font : Font;
import api.dm.kit.sprites.textures.texture : Texture;
import api.dm.kit.graphics.colors.rgba : RGBA;

import api.dm.kit.assets.fonts.bitmap.bitmap_font : BitmapFont;
import api.dm.kit.i18n.langs.alphabets.alphabet : Alphabet;
import api.math.geom2.rect2 : Rect2d;
import api.math.geom2.vec2 : Vec2d;

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
                            throw new Exception("Font FactoryKit error, texture size too small");
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

                    auto glyph = Glyph(letter, glyphPosition, Vec2d.init, alphabet, isEmpty, isNewline);

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
