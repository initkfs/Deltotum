module deltotum.ui.fonts.bitmap.bitmap_font_generator;

import deltotum.ui.fonts.font_generator : FontGenerator;
import deltotum.ui.fonts.glyphs.glyph : Glyph;

import deltotum.toolkit.asset.fonts.font : Font;
import deltotum.toolkit.display.textures.texture : Texture;
import deltotum.toolkit.graphics.colors.rgba: RGBA;

import deltotum.ui.fonts.bitmap.bitmap_font : BitmapFont;
import deltotum.toolkit.i18n.langs.alphabets.alphabet : Alphabet;
import deltotum.maths.shapes.rect2d : Rect2d;

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
    BitmapFont generate(Alphabet[] alphabets, Font font, RGBA foregroundColor = RGBA.white)
    {
        import deltotum.platform.sdl.sdl_surface : SdlSurface;
        import bindbc.sdl;

        //correct size?
        const int fontTextureWidth = 400;
        const int fontTextureHeight = 400;

        SdlSurface fontMapSurface = new SdlSurface;
        if(const err = fontMapSurface.createRGBSurface(0, fontTextureWidth, fontTextureHeight, 32, 0, 0, 0, 0xff)){
            throw new Exception(err.toString);
        }

        //TODO background
        SDL_SetColorKey(fontMapSurface.getObject, SDL_TRUE, SDL_MapRGBA(
                fontMapSurface.getObject.format, 0, 0, 0, 0));

        SDL_Rect glyphPosition;
        Glyph[] glyphs;

        //TTF_SetFontHinting(font.getObject, TTF_HINTING_MONO);

        foreach (alphabet; alphabets)
        {
            dstring allLetters = alphabet.allLetters;
            //TODO byGrapheme?
            foreach (i, dchar letter; allLetters)
            {
                const(char*) utfPtr = toUTFz!(const(char)*)([letter]);
                //TODO does SDL keep a reference?
                SdlSurface glyphRepresentation = font.renderSurface(utfPtr, foregroundColor);
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

                glyphs ~= Glyph(letter, Rect2d(glyphPosition.x, glyphPosition.y, glyphPosition.w, glyphPosition
                        .h), false, alphabet);

                if(const err = glyphRepresentation.blit(null, fontMapSurface.getObject, &glyphPosition)){
                    throw new Exception(err.toString);
                }
                glyphRepresentation.destroy;

                glyphPosition.x += glyphPosition.w;
            }
        }

        auto bitmapFont = new BitmapFont(glyphs);
        build(bitmapFont);
        bitmapFont.loadFromSurface(fontMapSurface);
        bitmapFont.setBlendMode;
        fontMapSurface.destroy;
        return bitmapFont;
    }
}
