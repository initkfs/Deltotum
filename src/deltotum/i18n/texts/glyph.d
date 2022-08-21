module deltotum.i18n.texts.glyph;

import deltotum.i18n.texts.alphabets.alphabet: Alphabet;

import deltotum.math.shapes.rect2d : Rect2d;

/**
 * Authors: initkfs
 */
struct Glyph
{
    @property Alphabet alphabet;
    @property dchar grapheme;
    @property Rect2d geometry;
    @property bool isEmpty = false;
}
