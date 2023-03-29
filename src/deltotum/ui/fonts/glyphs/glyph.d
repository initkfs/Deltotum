module deltotum.ui.fonts.glyphs.glyph;

import deltotum.toolkit.i18n.langs.alphabets.alphabet: Alphabet;

import deltotum.maths.shapes.rect2d : Rect2d;

/**
 * Authors: initkfs
 */
struct Glyph
{
    dchar grapheme;

    Rect2d geometry;
    bool isEmpty;

    Alphabet alphabet;
}
