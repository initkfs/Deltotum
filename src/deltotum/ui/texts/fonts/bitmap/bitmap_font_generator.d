module deltotum.ui.texts.fonts.bitmap.bitmap_font_generator;

import deltotum.ui.texts.fonts.font_generator : FontGenerator;
import deltotum.i18n.langs.glyph : Glyph;

import deltotum.asset.fonts.font : Font;
import deltotum.display.textures.texture : Texture;

import deltotum.ui.texts.fonts.bitmap.bitmap_font : BitmapFont;
import deltotum.i18n.langs.alphabets.alphabet : Alphabet;
import deltotum.math.shapes.rect2d : Rect2d;

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
    BitmapFont generate(Alphabet[] alphabets, Font font)
    {
        import deltotum.hal.sdl.sdl_surface : SdlSurface;
        import bindbc.sdl;

        //correct size?
        const int fontTextureWidth = 400;
        const int fontTextureHeight = 400;

        SdlSurface fontMapSurface = new SdlSurface;
        fontMapSurface.createRGBSurface(0, fontTextureWidth, fontTextureHeight, 32, 0, 0, 0, 0xff);
        SDL_SetColorKey(fontMapSurface.getStruct, SDL_TRUE, SDL_MapRGBA(
                fontMapSurface.getStruct.format, 0, 0, 0, 0));

        SDL_Rect glyphPosition;
        Glyph[] glyphs = [];
        SDL_Color foregroundColor = {255, 255, 255, 255};

        //TTF_SetFontHinting(font.getStruct, TTF_HINTING_MONO);

        foreach (alphabet; alphabets)
        {
            dstring allLetters = alphabet.allLetters;
            //TODO byGrapheme?
            foreach (i, dchar letter; allLetters)
            {
                const(char*) utfPtr = toUTFz!(const(char)*)([letter]);
                //TODO does SDL keep a reference?
                SDL_Surface* glyphRepresentation = TTF_RenderUTF8_Blended(font.getStruct, utfPtr, foregroundColor);
                glyphPosition.w = glyphRepresentation.w;
                glyphPosition.h = glyphRepresentation.h;

                if (glyphPosition.x + glyphPosition.w >= fontTextureWidth)
                {
                    glyphPosition.x = 0;

                    glyphPosition.y += glyphPosition.h + 1;

                    if (glyphPosition.y + glyphPosition.h >= fontTextureWidth)
                    {
                        throw new Exception("Font creation error, texture size too small");
                    }
                }

                glyphs ~= Glyph(alphabet, letter, Rect2d(glyphPosition.x, glyphPosition.y, glyphPosition.w, glyphPosition
                        .h));

                SDL_BlitSurface(glyphRepresentation, null, fontMapSurface.getStruct, &glyphPosition);

                SDL_FreeSurface(glyphRepresentation);

                glyphPosition.x += glyphPosition.w;
            }
        }

        auto bitmapFont = new BitmapFont(glyphs);
        build(bitmapFont);
        bitmapFont.loadFromSurface(fontMapSurface);
        fontMapSurface.destroy;
        return bitmapFont;
    }
}
