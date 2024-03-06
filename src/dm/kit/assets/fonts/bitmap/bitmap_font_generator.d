module dm.kit.assets.fonts.bitmap.bitmap_font_generator;

import dm.com.graphics.com_font : ComFontHinting, ComFont;
import dm.com.graphics.com_surface : ComSurface;
import dm.kit.assets.fonts.font_generator : FontGenerator;
import dm.kit.assets.fonts.glyphs.glyph : Glyph;
import dm.core.utils.provider : Provider;

import dm.kit.assets.fonts.font : Font;
import dm.kit.sprites.textures.texture : Texture;
import dm.kit.graphics.colors.rgba : RGBA;

import dm.kit.assets.fonts.bitmap.bitmap_font : BitmapFont;
import dm.kit.i18n.langs.alphabets.alphabet : Alphabet;
import dm.math.rect2d : Rect2d;
import dm.math.vector2 : Vector2;

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

    this(Provider!ComSurface comSurfaceProvider)
    {
        this.comSurfaceProvider = comSurfaceProvider;
    }

    BitmapFont generate(Alphabet[] alphabets, Font font, RGBA foregroundColor = RGBA.white, RGBA backgroundColor = RGBA
            .black)
    {
        //correct size?
        const int fontTextureWidth = 400;
        const int fontTextureHeight = 400;

        //The size can be very large to create on a stack
        ComSurface fontMapSurface = comSurfaceProvider.getNew();
        if (const err = fontMapSurface.createRGBSurface(fontTextureWidth, fontTextureHeight))
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
                dchar[1] letters = [letter];
                const(char*) utfPtr = toUTFz!(const(char)*)(letters[]);
                //TODO does SDL keep a reference?
                comSurfaceProvider.getNewScoped((glyphRepresentation) {
                    font.renderSurface(glyphRepresentation, utfPtr, foregroundColor, backgroundColor);
                    glyphPosition.width = glyphRepresentation.width;
                    glyphPosition.height = glyphRepresentation.height;

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
