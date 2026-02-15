module api.dm.kit.assets.fonts.bitmaps.alphabet_font_factory;

import api.dm.kit.assets.fonts.bitmaps.base_bitmap_font_factory : BaseBitmapFontFactory;

import api.dm.kit.components.graphic_component : GraphicComponent;
import api.dm.com.graphics.com_font : ComFont;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;

import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.graphics.colors.rgba : RGBA;

import api.dm.kit.assets.fonts.bitmaps.bitmap_font : BitmapFont;
import api.dm.kit.i18n.langs.alphabets.alphabet : Alphabet;
import api.math.geom2.rect2 : Rect2f;
import api.math.geom2.vec2 : Vec2f;

import std.string : toStringz;
import std.uni : byGrapheme;
import std.utf : toUTFz;
import std.stdio;

import Math = api.math;

/**
 * Authors: initkfs
 */
class AlphabetFontFactory : BaseBitmapFontFactory
{
    BitmapFont generate(
        Alphabet[] alphabets,
        ComFont font,
        RGBA foregroundColor = RGBA.white,
        RGBA backgroundColor = RGBA.black,
        int fontTextureWidth = defaultFontTextureWidth,
        int fontTextureHeight = defaultFontTextureWidth
    )
    {
        assert(fontTextureWidth > 0);
        assert(fontTextureHeight > 0);

        auto bitmapFont = newBitmapFont;
        ComSurface fontMapSurface = newFontSurface(font, fontTextureWidth, fontTextureHeight);

        Rect2f glyphPosition;
        Glyph[] glyphs;
        //TODO glyphs.reserve()

        foreach (alphabet; alphabets)
        {
            dstring allLetters = alphabet.allLetters;
            //TODO byGrapheme?
            generateToSurface(allLetters, fontMapSurface, font, (ref glyph, ref pos) {

                //TODO special?
                import std.uni : isWhite;
                import std.algorithm.comparison : among;

                glyph.alphabet = alphabet;

                bool isNewline;
                bool isEmpty = glyph.grapheme.isWhite;
                if (isEmpty)
                {
                    //FIXME \r\n
                    isNewline = glyph.grapheme.among('\n', '\r',) != 0;
                }

                glyph.isEmpty = isEmpty;
                glyph.isNEL = isNewline;

                //TODO config?
                if (glyph.grapheme == '𑑛' && bitmapFont.placeholder == Glyph.init)
                {
                    bitmapFont.placeholder = glyph;
                }

                if (glyph.grapheme == '0' && bitmapFont.e0 == Glyph.init)
                {
                    bitmapFont.e0 = glyph;
                }

                glyphs ~= glyph;

            }, foregroundColor, backgroundColor, glyphPosition);

        }

        bitmapFont.glyphs = glyphs;

        bitmapFont.loadFromSurface(fontMapSurface);
        fontMapSurface.dispose;
        bitmapFont.create;
        bitmapFont.blendModeBlend;

        return bitmapFont;
    }
}
