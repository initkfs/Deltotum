module deltotum.gui.fonts.glyphs.glyph;

import deltotum.kit.i18n.langs.alphabets.alphabet: Alphabet;

import deltotum.math.shapes.rect2d : Rect2d;

/**
 * Authors: initkfs
 */
struct Glyph
{
    dchar grapheme;

    Rect2d geometry;
    bool isEmpty;
    bool isCarriageReturn;

    Alphabet alphabet;
}
