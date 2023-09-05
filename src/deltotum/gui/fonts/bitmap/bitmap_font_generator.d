module deltotum.gui.fonts.bitmap.bitmap_font_generator;

import deltotum.gui.fonts.font_generator : FontGenerator;
import deltotum.gui.fonts.glyphs.glyph : Glyph;

import deltotum.kit.assets.fonts.font : Font;
import deltotum.kit.sprites.textures.texture : Texture;
import deltotum.kit.graphics.colors.rgba : RGBA;

import deltotum.gui.fonts.bitmap.bitmap_font : BitmapFont;
import deltotum.kit.i18n.langs.alphabets.alphabet : Alphabet;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.vector2d: Vector2d;

import bindbc.sdl;

import std.string : toStringz;
import std.uni : byGrapheme;
import std.utf : toUTFz;
import std.stdio;

/**
 * Authors: initkfs
 */
class BitmapFontGenerator : FontGenerator
{
    BitmapFont generate(Alphabet[] alphabets, Font font, RGBA foregroundColor = RGBA.white, RGBA backgroundColor = RGBA
            .black)
    {
        import deltotum.sys.sdl.sdl_surface : SdlSurface;
        import bindbc.sdl;

        //correct size?
        const int fontTextureWidth = 400;
        const int fontTextureHeight = 400;

        SdlSurface fontMapSurface = new SdlSurface;
        if (const err = fontMapSurface.createRGBSurface(0, fontTextureWidth, fontTextureHeight, 32, 0, 0, 0, 0xff))
        {
            throw new Exception(err.toString);
        }

        //TODO background
        SDL_SetColorKey(fontMapSurface.getObject, SDL_TRUE, SDL_MapRGBA(
                fontMapSurface.getObject.format, 0, 0, 0, 0));

        SDL_Rect glyphPosition;
        Glyph[] glyphs;

        TTF_SetFontHinting(font.font.getObject, TTF_HINTING_NORMAL);

        auto bitmapFont = new BitmapFont;
        build(bitmapFont);

        foreach (alphabet; alphabets)
        {
            dstring allLetters = alphabet.allLetters;
            //TODO byGrapheme?
            foreach (i, dchar letter; allLetters)
            {
                dchar[1] letters = [letter];
                const(char*) utfPtr = toUTFz!(const(char)*)(letters[]);
                //TODO does SDL keep a reference?
                SdlSurface glyphRepresentation = font.renderSurface(utfPtr, foregroundColor, backgroundColor);
                glyphPosition.w = glyphRepresentation.getObject.w;
                glyphPosition.h = glyphRepresentation.getObject.h;
                
                if (glyphPosition.x + glyphPosition.w >= fontTextureWidth)
                {
                    glyphPosition.x = 0;

                    glyphPosition.y += glyphPosition.h + 1;

                    if (glyphPosition.y + glyphPosition.h >= fontTextureWidth)
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

                auto glyph = Glyph(letter, Rect2d(glyphPosition.x, glyphPosition.y, glyphPosition.w, glyphPosition
                        .h), Vector2d.init, alphabet, isEmpty, isNewline);

                //TODO config?
                if (glyph.grapheme == '𑑛')
                {
                    bitmapFont.placeholder = glyph;
                }

                glyphs ~= glyph;

                if (const err = glyphRepresentation.blit(null, fontMapSurface.getObject, &glyphPosition))
                {
                    throw new Exception(err.toString);
                }
                glyphRepresentation.destroy;

                glyphPosition.x += glyphPosition.w;
            }
        }

        bitmapFont.glyphs = glyphs;

        bitmapFont.loadFromSurface(fontMapSurface);
        bitmapFont.setBlendMode;
        fontMapSurface.destroy;
        return bitmapFont;
    }
}
